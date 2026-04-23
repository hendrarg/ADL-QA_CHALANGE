# README

Ini adalah panduan untuk menjalankan aplikasi API sederhana (FastAPI) di local environment.

## Prasyarat
- Python 3.7+ sudah terinstall.

## Langkah-langkah

1. **Cek apakah Python sudah terinstall**
   - **Windows**: Buka Command Prompt atau PowerShell.
   - **macOS**: Buka Terminal.

   Jalankan perintah:
   ```bash
   python --version
   ```
   > **Note untuk macOS**: Jika `python` tidak dikenal, coba ketik `python3 --version`.
   
   - Jika muncul tulisan seperti `Python 3.x.x` (misal 3.10.1), berarti aman. Lanjut ke step berikutnya.
   - Jika error atau perintah tidak dikenali, download dan install Python dulu dari [python.org](https://www.python.org/downloads/). 
     > **PENTING (Windows):** Saat install, jangan lupa centang opsi **"Add Python to PATH"**.

2. **Buat Virtual Environment (Opsional tapi direkomendasikan)**
   ```bash
   python -m venv venv
   ```

3. **Aktifkan Virtual Environment**
   - Windows:
     ```bash
     .\venv\Scripts\activate
     ```
   - macOS/Linux:
     ```bash
     source venv/bin/activate
     ```
   
   > **Jika gagal mengaktifkan virtual environment**: Tidak masalah, skip langkah 2 dan 3, lanjut langsung ke step 4. Dependencies akan terinstall secara global di sistem Python Anda.

4. **Install Dependencies**
   ```bash
   pip install -r requirements.txt
   ```

5. **Jalankan Aplikasi**
   ```bash
   python main.py
   ```

6. **Cek Aplikasi**
   Buka browser dan akses:
   - Root: [http://localhost:8010](http://localhost:8010) -> Output: `{"message": "Hello World"}`
   - Documentation: [http://localhost:8010/docs](http://localhost:8010/docs)

## Troubleshooting

### Port 8010 sudah digunakan
Jika muncul error `Address already in use`:

**Windows:**
1. Cari proses yang menggunakan port 8010:
   ```bash
   netstat -ano | findstr :8010
   ```
2. Catat nomor PID dari hasil output (kolom terakhir)
3. Matikan proses tersebut (ganti <PID> dengan nomor yang didapat):
   ```bash
   taskkill /PID <PID> /F
   ```
4. Jalankan ulang aplikasi

**macOS/Linux:**
1. Matikan proses yang menggunakan port 8010:
   ```bash
   lsof -ti:8010 | xargs kill -9
   ```
2. Jalankan ulang aplikasi

### Module tidak ditemukan
Jika muncul error `ModuleNotFoundError`:
1. Pastikan Anda berada di folder project yang benar
2. Install ulang dependencies:
   ```bash
   pip install -r requirements.txt
   ```
3. Tunggu hingga instalasi selesai
4. Jalankan ulang aplikasi dengan `python main.py`

### pip tidak dikenali
**Windows:**
1. Gunakan command alternatif:
   ```bash
   python -m pip install -r requirements.txt
   ```
2. Jika masih error, pastikan Python sudah ditambahkan ke PATH saat instalasi

**macOS/Linux:**
1. Coba gunakan pip3:
   ```bash
   pip3 install -r requirements.txt
   ```
2. Atau gunakan:
   ```bash
   python3 -m pip install -r requirements.txt
   ```

### Aplikasi tidak bisa diakses
1. Cek terminal, pastikan tidak ada error saat aplikasi berjalan
2. Pastikan muncul pesan seperti "Uvicorn running on http://127.0.0.1:8010"
3. Coba akses URL alternatif:
   - [http://localhost:8010](http://localhost:8010)
   - [http://127.0.0.1:8010](http://127.0.0.1:8010)
4. Jika masih tidak bisa, restart aplikasi:
   - Tekan Ctrl+C di terminal untuk stop aplikasi
   - Jalankan ulang dengan `python main.py`
5. Refresh browser setelah aplikasi berjalan kembali
