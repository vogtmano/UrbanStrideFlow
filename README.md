# UrbanStride & Flow 🏃‍♂️💼
> Grywalizacja ruchu miejskiego i biurowego. Aplikacja natywna iOS wspierająca walkę z "epidemią siedzenia".

---

## 📌 O Projekcie
**UrbanStride & Flow** to nowoczesna aplikacja mobilna stworzona z myślą o osobach prowadzących siedzący tryb życia – pracownikach biurowych oraz osobach na Home Office. Projekt łączy monitorowanie aktywności na zewnątrz z krótkimi sesjami ruchowymi wewnątrz budynków. Aplikacja wdraża zaawansowane elementy grywalizacji, skutecznie nagradzając użytkowników za codzienne, prozdrowotne wybory.

### Key Features (Główne Funkcjonalności)
* **Grywalizacja aktywności:** Punkty i odznaki za wybieranie schodów zamiast windy oraz realizację mikro-przemieszczeń.
* **Sesje "Flow":** Krótkie, 3-minutowe, kierowane sesje rozciągające redukujące napięcia mięśniowe.
* **Inteligentny Asystent Przerw:** Wykrywanie braku aktywności w czasie rzeczywistym i personalizowane powiadomienia push.
* **Analityka Zdrowia:** Dziennik postępów, statystyki kroków oraz zrealizowanych przerw w pracy.

---

## 📸 Interfejs Aplikacji (UI)

| **Ekran Główny** | **Sesja Rozciągania (Flow)** | **Statystyki i Odznaki** |
| :---: | :---: | :---: |
| <img src="https://github.com/user-attachments/assets/c08adef6-4323-41a5-9b96-7c10872016b4" width="220" alt="Ekran Główny" /> | <img src="https://github.com/user-attachments/assets/2bddb144-e607-4feb-8aa8-22295d697f0c" width="220" alt="Sesja Flow" /> | <img src="https://github.com/user-attachments/assets/f3b4071b-8c67-45b2-9263-88f9ef89c756" width="220" alt="Statystyki" /> |

> 💡 Aby zobaczyć interfejs w akcji bez pobierania kodu, powyżej umieszczono zrzuty ekranu prosto z symulatora iOS.

---

## 🚀 Proces Projektowy (UX/UI & Dev)

### 1. Research and Discovery (Analiza i Odkrywanie)
Projekt rozpoczął się od szczegółowej analizy problemu siedzącego trybu życia. Badania ergonomii pracy jednoznacznie wykazują, że regularne, bardzo krótkie przerwy na ruch (tzw. **movement snacks**) wykazują znacznie lepszy wpływ na metabolizm, układ krążenia i zdrowie kręgosłupa niż jeden intensywny trening wykonany po 8 godzinach ciągłego bezruchu.

### 2. Define Goals and Objectives (Definiowanie Celów)
* **Zwiększenie dziennej liczby kroków** o minimum 20% poprzez system mikro-zadań w przestrzeni miejskiej.
* **Wdrożenie nawyku** 3-minutowego rozciągania (Flow) co 90 minut pracy przy biurku.
* **Cel zdrowotny:** Redukcja bólów kręgosłupa i spięć mięśniowych u pracowników umysłowych.

### 3. Development and Implementation (Technologia)
Aplikacja została zbudowana jako w pełni natywne rozwiązanie systemowe przy użyciu najnowszego stosu technologicznego Apple:
* **Framework:** `SwiftUI` (deklaratywny interfejs użytkownika zapewniający płynne animacje).
* **Integracja systemowa:** `HealthKit` (pobieranie danych o krokach, dystansie i pokonanych piętrach w tle).
* **Sensory:** `CoreMotion` oraz akcelerometr wykorzystywane do detekcji długotrwałego bezruchu użytkownika.
* **Powiadomienia:** Lokalny system `UserNotifications` optymalizujący moment wysłania przypomnienia o przerwie.
* **Architektura:** Projekt strukturyzowany zgodnie z wzorcem **MVVM** (Models, Views, ViewModels, Services).

### 4. Testing and Iteration (Testy i Ulepszenia)
W fazie beta przeprowadzono testy użyteczności (Usability Testing) w grupie osób pracujących zdalnie.
* **Kluczowa Iteracja:** Pierwotne sesje ćwiczeń trwały 10 minut. Testy wykazały, że użytkownicy masowo je pomijali z powodu braku czasu w trakcie spotkań i zadań. Na podstawie feedbacku **skrócono sesje do 3 minut**, co skutkowało drastycznym (niemal trzykrotnym) wzrostem wskaźnika ukończonych aktywności w ciągu dnia pracy.

---

## 🛠 Wymagania i Uruchomienie

Przed uruchomieniem upewnij się, że posiadasz środowisko kompatybilne z poniższą specyfikacją:
* Komputer Mac z systemem **macOS Sonoma (14.0)** lub nowszym.
* Środowisko **Xcode 15.0** lub nowsze.
* Cel kompilacji: **iOS 17.0+** (rekomendowane testowanie na fizycznym urządzeniu ze względu na integrację z Apple HealthKit).

## 👥 Autor
* **Maksymilian Vogtman** – *iOS Developer & future UX/UI Designer*
* Projekt zrealizowany w ramach przedmiotu: *Projektowanie Aplikacji Mobilnych*
