## 📁 Struktura Repozytorium
* `ADSM.srcs/` – kod Verilog, wzorce `.coe` i konfiguracje IP (`.xci`)
* `build_project.tcl` – skrypt generujący projekt Vivado
* `matlab/` – skrypty matlabowe
* `architecture/` – architektura systemu
* `.gitignore` – automatycznie odcina śmieci (logi, cache, wyniki syntezy)

---

## 🛠️ Odtwarzanie Projektu
1. Pobierz repo: `git clone <link>`
2. Otwórz Vivado.
3. W **Tcl Console** (na dole ekranu) wpisz:
   ```tcl
   cd <ścieżka_do_repo>
   source build_project.tcl
    ```

## 🌿 Praca na Branchach

1. **Stwórz nowy branch** przed rozpoczęciem nowego taska:
   ```bash
   git checkout -b feature/nazwa-funkcji
2. **Pracuj i testuj** twoje zmiany nie wpływają na pracę innych, dopóki ich nie zmergeujemy.
3. **Wyślij swój branch** 
    ```bash
    git push origin feature/nazwa-funkcji
4. **Merge** Gdy już spushowaliśmy brancha, robimy pull request na githubie, czekamy aż ktoś z nas zerknie na zmiany i scalamy.

## 💾 Commitowanie i Zapisywanie Zmian
1. **Zaktualizuj skrypt projektu (w vivado tcl console)**
    ```bash
    cd [get_property DIRECTORY [current_project]]
    write_project_tcl -force build_project.tcl
    ```
2. Dodaj zmiany
    ```bash
    git add .
    git commit -m "Krótki opis zmian (np. Dodano filtr FIR, Zmiana rozmiaru ROM)"
    git push origin <twój-aktualny-branch>
    ```

## Czego nie robimy?
- Nie wrzucajmy plików .xpr, .cache, .hw, .runs, nawet jeśli .gitignore je pominie
