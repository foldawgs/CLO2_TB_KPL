import requests


API_KEY = "49c58e15ae044fbe9bea30cae91e81d1"
API_URL = f"https://api.currencyfreaks.com/v2.0/rates/latest?apikey={API_KEY}"

def convert_currency(amount: float, from_currency: str, to_currency: str) -> float:
    try:
        response = requests.get(API_URL)
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
    amount = float(input("Masukkan jumlah uang: "))
    from_currency = input("Dari mata uang (contoh: IDR): ").upper()
    to_currency = input("Ke mata uang (contoh: USD): ").upper()


    hasil = convert_currency(amount, from_currency, to_currency)
    print(f"\nHasil konversi: {hasil:.2f} {to_currency}")

except ValueError as e:
    print(f"Error: {e}")
except Exception as e:
    print(f"Terjadi kesalahan: {e}")