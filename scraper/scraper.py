"""
Industrial Procurement Scraper
--------------------------------
Scrapes product listing data from IndustryBuying (Power Tools category).

Output:
    raw_data.csv  -> contains raw JSON payload for each product listing

Purpose:
    This file collects raw, unmodified product data which will later be
    structured inside Snowflake and transformed using dbt models.

Author: Data Engineering Assessment
"""

import requests
from bs4 import BeautifulSoup
import json
import pandas as pd
import time
from datetime import datetime
from typing import List, Dict

# ============================================================
# Configuration
# ============================================================

BASE_URL = "https://www.industrybuying.com"
HEADERS = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
}

# Limits to keep scraping controlled for the assessment
MAX_CATEGORIES = 10
MAX_PRODUCTS_PER_CATEGORY = 50

REQUEST_DELAY = 1  # seconds between requests (avoid blocking)


# ============================================================
# Utility Functions
# ============================================================

def fetch_html(url: str) -> BeautifulSoup:
    """
    Fetch a webpage and return a BeautifulSoup object.
    Basic error handling.
    """
    try:
        response = requests.get(url, headers=HEADERS, timeout=30)
        response.raise_for_status()
        return BeautifulSoup(response.text, "lxml")

    except requests.RequestException as e:
        print(f"[ERROR] Failed to fetch URL: {url}")
        print(e)
        return None


# ============================================================
# Step 1: Discover Subcategories
# ============================================================

def get_subcategories() -> List[str]:
    """
    Extracts subcategory URLs under Power Tools category.
    """
    print("\n[INFO] Fetching subcategories...")

    url = f"{BASE_URL}/power-tools-641"
    soup = fetch_html(url)

    if soup is None:
        return []

    subcategories = []

    for a in soup.find_all("a", href=True):
        href = a["href"]

        # Match only subcategory URLs
        if href.startswith("/power-tools-641/") and href.count("/") == 2:
            if "all-products" not in href:

                full_url = BASE_URL + href

                if full_url not in subcategories:
                    subcategories.append(full_url)

    print(f"[INFO] Found {len(subcategories)} subcategories")
    return subcategories[:MAX_CATEGORIES]


# ============================================================
# Step 2: Extract Product JSON
# ============================================================

def extract_products(json_data: Dict, page_url: str, category_name: str) -> List[Dict]:
    """
    Traverses embedded JSON and extracts product listing objects.
    """
    products = []

    def traverse(obj):
        """Recursive JSON traversal."""
        if isinstance(obj, dict):

            # Identify product widget
            if obj.get("type") == "PRODUCT_SUMMARY_LIST":

                for item in obj["data"]["renderableComponents"]:
                    value = item["value"]

                    record = {
                        "category": category_name,
                        "page_url": page_url,
                        "scraped_at": datetime.utcnow().strftime("%Y-%m-%d %H:%M:%S"),
                        "raw_product_json": json.dumps(value)  # raw payload
                    }

                    products.append(record)

            for v in obj.values():
                traverse(v)

        elif isinstance(obj, list):
            for i in obj:
                traverse(i)

    traverse(json_data)
    return products


# ============================================================
# Step 3: Scrape One Subcategory
# ============================================================

def scrape_subcategory(subcat_url: str) -> List[Dict]:
    """
    Iterates through paginated subcategory pages and collects product data.
    """

    print(f"\n[INFO] Scraping subcategory: {subcat_url}")

    category_name = subcat_url.split("/")[-1]
    collected_products = []
    page = 1

    while len(collected_products) < MAX_PRODUCTS_PER_CATEGORY:

        page_url = f"{subcat_url}?page={page}"
        print(f"   -> Page {page}")

        soup = fetch_html(page_url)
        if soup is None:
            break

        # Find hydration JSON inside script tag
        target_script = None
        for script in soup.find_all("script"):
            if script.string and "PRODUCT_SUMMARY_LIST" in script.string:
                target_script = script.string
                break

        if not target_script:
            print("[WARN] No product script found. Possibly last page.")
            break

        # Extract JSON safely
        try:
            start = target_script.find("{")
            end = target_script.rfind("}") + 1
            data = json.loads(target_script[start:end])
        except Exception:
            print("[ERROR] Failed to parse product JSON")
            break

        page_products = extract_products(data, page_url, category_name)

        if not page_products:
            break

        # Limit products
        for product in page_products:
            if len(collected_products) < MAX_PRODUCTS_PER_CATEGORY:
                collected_products.append(product)
            else:
                break

        page += 1
        time.sleep(REQUEST_DELAY)

    print(f"[INFO] Collected {len(collected_products)} products")
    return collected_products


# ============================================================
# Step 4: Main Pipeline
# ============================================================

def run_scraper():
    """
    Main orchestrator for the scraping process.
    """

    print("\n========== STARTING SCRAPER ==========")

    dataset = []
    subcategories = get_subcategories()

    if not subcategories:
        print("[ERROR] No subcategories found. Exiting.")
        return

    for subcategory in subcategories:
        products = scrape_subcategory(subcategory)
        dataset.extend(products)

    # Convert to DataFrame
    df = pd.DataFrame(dataset)

    print(f"\n[INFO] Total records collected: {len(df)}")

    # Save output
    output_file = "../scraper/output/raw_data.csv"
    df.to_csv(output_file, index=False)

    print(f"[INFO] Saved dataset -> {output_file}")
    print("========== SCRAPER COMPLETE ==========")


# ============================================================
# Entry Point
# ============================================================

if __name__ == "__main__":
    run_scraper()
