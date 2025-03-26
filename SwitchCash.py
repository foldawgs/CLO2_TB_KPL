import requests

API_KEY = "49c58e15ae044fbe9bea30cae91e81d1"
RATES_URL = f"https://api.currencyfreaks.com/v2.0/rates/latest?apikey={API_KEY}"
SYMBOLS_URL = f"https://api.currencyfreaks.com/v2.0/currency-symbols"

def fetch_currency_symbols():
    try:
        response = requests.get(SYMBOLS_URL)
        response.raise_for_status()
        data = response.json()
        currency_symbols = data.get("currencySymbols", {})
        return {code: name for code, name in list(currency_symbols.items())[:20]}  
    except requests.exceptions.RequestException as e:
        raise Exception("Gagal mengambil data simbol mata uang. Periksa koneksi atau API key.") from e

def display_currency_options(currency_symbols):
    print("Daftar Mata Uang yang Tersedia:")
    for code, name in currency_symbols.items():
        print(f"{code}: {name}")

def convert_currency(amount: float, from_currency: str, to_currency: str) -> float:
    try:
        response = requests.get(RATES_URL)
        response.raise_for_status()
        data = response.json()
        rates = data.get("rates", {})

        if from_currency not in rates or to_currency not in rates:
            raise ValueError(f"Mata uang tidak ditemukan: {from_currency} atau {to_currency}")

        from_rate = float(rates[from_currency])
        to_rate = float(rates[to_currency])

        if from_currency != "USD":
            amount = amount / from_rate

        converted_amount = amount * to_rate

        print(f"\nKurs {from_currency} → USD: {from_rate}")
        print(f"Kurs USD → {to_currency}: {to_rate}")
        return converted_amount

    except requests.exceptions.RequestException as e:
        raise Exception("Gagal mengambil data kurs. Periksa koneksi atau API key.") from e

try:
    currency_symbols = fetch_currency_symbols()
    display_currency_options(currency_symbols)  
    amount = float(input("\nMasukkan jumlah uang: "))
    from_currency = input("Dari mata uang: ").upper()
    to_currency = input("Ke mata uang: ").upper()

    hasil = convert_currency(amount, from_currency, to_currency)
    print(f"\nHasil konversi: {hasil:.2f} {to_currency}")

except ValueError as e:
    print(f"Error: {e}")
except Exception as e:
    print(f"Terjadi kesalahan: {e}")
