# README



Repositori ini berisi API sederhana berbasis **FastAPI** (port **8010**), folder **`robot/`** untuk pengujian **Robot Framework**, dan koleksi contoh **`ADL/`** untuk **Bruno**.



## Prasyarat



- **Python 3.9+** (disarankan 3.10 atau 3.11).

- Terminal (PowerShell di Windows, atau bash/zsh di macOS/Linux).



## Struktur singkat



| Folder / file | Keterangan |

|---------------|------------|

| `app/` | Modul FastAPI (`app.server:app`). |

| `main.py` | Entry point; menjalankan Uvicorn. |

| `requirements.txt` | Dependensi API. |

| `requirements-robot.txt` | Dependensi untuk tes Robot. |

| `robot/` | Suite tes `.robot`. |

| `ADL/` | Request Bruno (YAML) untuk eksplorasi API. |



Tabel di atas hanya **level atas**. Struktur folder sebenarnya bertingkat; ringkasan pohon **inti** (tanpa `venv/`, cache Python, atau artefak laporan Robot seperti `log.html` / `output.xml` yang dihasilkan saat tes jalan):



```

qa_challange/

├── app/

│   ├── db.py

│   └── server.py

├── ADL/

│   ├── environments/

│   │   └── Test.yml

│   ├── detail invoice.yml

│   ├── list invoice.yml

│   ├── login.yml

│   ├── opencollection.yml

│   └── unbiled invoice.yml

├── robot/

│   ├── resources/

│   │   ├── common.resource

│   │   └── invoice_api_bdd.resource

│   └── tests/

│       ├── http_status_matrix_bdd.robot

│       ├── invoice_list_vs_detail_bdd.robot

│       └── unbilled_summary_bdd.robot

├── main.py

├── requirements.txt

├── requirements-robot.txt

├── pytest.ini

├── README.md

├── bug_report.txt

├── SOAL.pdf

└── .vscode/

    └── settings.json

```



## Menjalankan API (lokal)



**Penting:** jalankan semua perintah di bawah dari **akar repositori** (folder yang berisi `README.md`, `main.py`, dan `requirements.txt`). Jika terminal membuka folder induk yang salah, Anda akan mendapat error seperti `can't open file '...\\main.py'`.



1. **Cek Python**



   ```bash

   python --version

   ```



   Di macOS, jika `python` tidak ada, gunakan `python3 --version`.  

   Instalasi Windows: centang **Add Python to PATH** di [python.org](https://www.python.org/downloads/).



2. **Virtual environment (disarankan)**



   ```bash

   python -m venv venv

   ```



3. **Aktifkan venv**



   - **Windows (PowerShell):**



     ```powershell

     .\venv\Scripts\Activate.ps1

     ```



     Jika eksekusi script ditolak, jalankan sekali (PowerShell sebagai Administrator):  

     `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`



   - **Windows (cmd):**



     ```bat

     venv\Scripts\activate.bat

     ```



   - **macOS / Linux:**



     ```bash

     source venv/bin/activate

     ```



4. **Install dependensi API**



   ```bash

   python -m pip install -r requirements.txt

   ```



5. **Jalankan aplikasi**



   ```bash

   python main.py

   ```



6. **Cek di browser**



   - Root: [http://localhost:8010](http://localhost:8010) — contoh: `{"message": "Hello World"}` (sesuai implementasi `app/server.py`).

   - Dokumentasi interaktif: [http://localhost:8010/docs](http://localhost:8010/docs)



## Menjalankan tes Robot (opsional)



Dari akar repositori, setelah venv aktif, instal dependensi Robot **sekali**:



```bash

python -m pip install -r requirements-robot.txt

```



Di **Windows**, kalau perintah `robot` tidak dikenali (`The term 'robot' is not recognized`), itu biasanya karena folder `Scripts` Python tidak ada di **PATH**. Gunakan bentuk **`python -m robot ...`** di bawah (disarankan), atau tambahkan ke PATH misalnya `C:\Users\<Anda>\AppData\Roaming\Python\Python311\Scripts` (sesuaikan versi Python). Di venv yang aktif, `robot` biasanya sudah bisa dipanggil langsung.



### Menjalankan semua test case di `robot/tests`

Menjalankan **semua** file `.robot` di bawah folder tersebut:



```bash

python -m robot robot/tests

```



(Persamaan jika `robot` ada di PATH: `robot robot/tests`.)



### Menjalankan menurut file (satu atau beberapa suite)

Satu file:



```bash

python -m robot robot/tests/http_status_matrix_bdd.robot

```



Beberapa file sekaligus:



```bash

python -m robot robot/tests/invoice_list_vs_detail_bdd.robot robot/tests/unbilled_summary_bdd.robot

```



### Menjalankan menurut tag (`[Tags]` pada test case)

Di suite proyek ini dipakai tag antara lain: `bdd`, `bag2`, `bag3`, `bag4`, `login`, `invoices`, `detail`, `unbilled`, `api`, `spec_gap`. Hanya tes yang **memiliki tag** yang cocok yang dijalankan.

Hanya tes bertag `login`:



```bash

python -m robot -i login robot/tests

```



Tes harus punya tag `bdd` **dan** `bag4` (beberapa `-i` = AND):



```bash

python -m robot -i bdd -i bag4 robot/tests

```



Lewati tes bertag `spec_gap`:



```bash

python -m robot -e spec_gap robot/tests

```



Batasi ke satu file **plus** filter tag:



```bash

python -m robot -i invoices robot/tests/http_status_matrix_bdd.robot

```



Dokumentasi resmi Robot Framework: [tagging](https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html#tagging-test-cases), [menjalankan tes / opsi `-i` dan `-e`](https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html#executing-test-cases).



**Catatan:** target API default tes adalah `http://localhost:8010`. Untuk base URL lain, set environment variable `API_BASE_URL` sebelum menjalankan tes (lihat `robot/resources/common.resource`).



## Bruno / Cursor



File di **`ADL/`** dapat dibuka sebagai koleksi di **Bruno** (aplikasi desktop atau ekstensi di Cursor/VS Code).



- Login biasanya mengembalikan field **`token`** (bukan `access_token`). Di **Post Response**, contoh: baca `res.getBody().token` lalu `bru.setEnvVar("access_token", ..., { persist: true })`.

- Di **ekstensi Bruno di Cursor**, penyimpanan variabel lingkungan ke **file** dari script kadang tidak sama dengan aplikasi desktop; untuk token yang harus tetap setelah restart, gunakan **Bruno desktop**, isi manual di environment, atau jalankan login lagi per sesi.



## Troubleshooting



### Port 8010 sudah digunakan



**Windows:**



1. `netstat -ano | findstr :8010`

2. Catat PID (kolom terakhir).

3. `taskkill /PID <PID> /F`

4. Jalankan ulang `python main.py`



**macOS / Linux:**



```bash

lsof -ti:8010 | xargs kill -9

```



### `can't open file '...main.py'`



Anda tidak berada di folder yang berisi `main.py`. `cd` ke akar repositori (lihat bagian struktur di atas), lalu `python main.py`.



### `ModuleNotFoundError` (mis. `uvicorn`)



1. Pastikan venv aktif (prompt biasanya diawali `(venv)`).

2. Install ulang: `python -m pip install -r requirements.txt`

3. Pastikan `python` yang dipakai sama dengan yang memasang paket: `python -c "import sys; print(sys.executable)"`



### `pip` tidak dikenali (Windows)



Gunakan:



```bash

python -m pip install -r requirements.txt

```



### Aplikasi tidak bisa diakses dari browser



1. Lihat terminal: pastikan tidak ada traceback; harus ada indikasi Uvicorn listening di `8010`.

2. Coba [http://127.0.0.1:8010](http://127.0.0.1:8010) selain `localhost`.

3. Stop dengan Ctrl+C, lalu jalankan lagi `python main.py`.



### PowerShell: `&&` tidak valid



Di PowerShell lawas, rangkai perintah dengan `;` atau jalankan perintah terpisah, misalnya:



```powershell

cd C:\path\ke\qa_challange

python -m pip install -r requirements.txt

```
