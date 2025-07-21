import sys

if len(sys.argv) < 2:
    print("Brak nazwy pliku!")
    exit(1)

filename = sys.argv[1]
print(f"Odebrano nazwę pliku: {filename}")

# Tu podłącz Selenium (np. otwórz stronę EPLAN i coś kliknij)
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.options import Options

options = Options()
options.add_argument("--start-maximized")
driver = webdriver.Chrome(service=Service(), options=options)

driver.get("https://example.com")  # Zastąp adresem EPLAN Smart Production
# Dodaj obsługę pliku (np. wczytanie, kliknięcia itp.)

input("Naciśnij Enter, aby zamknąć przeglądarkę...")
driver.quit()
