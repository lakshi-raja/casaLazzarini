# Parallel Phase Contract — Casa Lazzarini

**Freeze date:** 2026-09-30  
**Status:** LOCKED — nessuna modifica ai file condivisi senza aggiornare questo documento.

---

## 1. Routing Contract

### Route constants (`lib/core/routing/app_routes.dart`) — SHARED/PROTECTED

| Costante | Path | Owner registrazione in app_router |
|---|---|---|
| `splash` | `/` | Phase 1 ✅ done |
| `login` | `/login` | Phase 1 ✅ done |
| `home` | `/home` | Phase 1 ✅ done |
| `booking` | `/booking` | **Phase 2** |
| `bookingDetail` | `/booking/:bookingId` | **Phase 2** (se necessario) |
| `admin` | `/admin` | Phase 1 ✅ done |
| `adminBookings` | `/admin/bookings` | **Phase 3** |

### Regole di integrazione per `app_router.dart`

- **Phase 2** aggiunge le `GoRoute` per `booking` e `bookingDetail` nella lista `routes:` dopo il route `/home`.
- **Phase 3** aggiunge la `GoRoute` per `adminBookings` come sub-route o route piatta dopo `/admin`.
- Il guard admin usa `location.startsWith(AppRoutes.admin)` — copre già tutti i sub-path. **Non cambiare questa logica.**
- `app_router.dart` è un **hotspot di merge** — Phase 2 e Phase 3 devono inserire i propri GoRoute in aree separate della lista per minimizzare conflitti.

---

## 2. Repository Contracts

### IBookingRepository — `lib/features/bookings/domain/i_booking_repository.dart`

**Owner implementazione: Phase 2**  
Phase 3 usa solo lettura tramite un provider separato (`adminBookingsProvider`) che può istanziare la stessa implementazione concreta.

| Metodo | Ritorna | Note |
|---|---|---|
| `getMyBookings()` | `Future<List<Booking>>` | Filtra per utente corrente (RLS) |
| `getUnavailableDates(suiteId)` | `Future<List<DateTime>>` | Date con tutti e 3 i BookingType occupati |
| `getBookedTypesForDate(suiteId, date)` | `Future<List<BookingType>>` | Slot occupati per data/suite |
| `createBooking({suiteId, date, type})` | `Future<Booking>` | Throw su conflitto (DB unique index) |
| `cancelBooking(bookingId)` | `Future<void>` | Soft-delete: status → CANCELLED |

### ISuiteRepository — `lib/shared/repositories/i_suite_repository.dart`

**Shared** (Phase 2 + Phase 3, implementazione concreta può essere una sola)

| Metodo | Ritorna | Chi lo usa |
|---|---|---|
| `getActiveSuites()` | `Future<List<Suite>>` | Phase 2 + Phase 3 |
| `getSuiteById(id)` | `Future<Suite>` | Phase 2 + Phase 3 |
| `updateSuite(suite)` | `Future<Suite>` | Phase 3 only (RLS blocca utenti normali) |

---

## 3. Provider Ownership

| Provider | Owner | Altri agent |
|---|---|---|
| `appAuthProvider` | Phase 1 / auth ✅ | Read-only per tutti |
| `routerProvider` | Phase 1 / routing ✅ | Read-only per tutti |
| `bookingRepositoryProvider` | **Phase 2** | Phase 3 può leggere |
| `suiteRepositoryProvider` | **Phase 2** (crea la concreta) | Phase 3 usa read-only |
| `myBookingsProvider` | **Phase 2** | — |
| `availabilityProvider` | **Phase 2** | — |
| `adminBookingsProvider` | **Phase 3** | — |
| `adminSuiteProvider` | **Phase 3** | — |

**Regola:** Phase 3 non crea una seconda implementazione di `ISuiteRepository`. Usa `suiteRepositoryProvider` definito da Phase 2, o crea `adminSuiteRepositoryProvider` che istanzia la stessa classe concreta.

---

## 4. File Ownership

### Agent 1 — Phase 1.5 Design

| Permesso | Directory / File |
|---|---|
| ✅ Modifica libera | `lib/core/theme/**` |
| ✅ Modifica libera | `lib/shared/widgets/**` |
| ✅ Modifica libera | `lib/features/home/presentation/home_screen.dart` |
| ✅ Modifica libera | `lib/features/auth/presentation/**` |
| 🔒 NO TOUCH | `lib/core/routing/**` |
| 🔒 NO TOUCH | `lib/features/auth/domain/**` |
| 🔒 NO TOUCH | `lib/shared/models/**` |
| 🔒 NO TOUCH | `lib/shared/repositories/**` |
| 🔒 NO TOUCH | `lib/features/bookings/**` |
| 🔒 NO TOUCH | `lib/features/admin/**` |
| 🔒 NO TOUCH | `supabase/**` |

### Agent 2 — Phase 2 Booking

| Permesso | Directory / File |
|---|---|
| ✅ Owns completamente | `lib/features/bookings/**` |
| ✅ Owns completamente | `lib/features/calendar/**` |
| ✅ Crea implementazione | `lib/shared/repositories/suite_repository.dart` (concreta) |
| ✅ Crea implementazione | `lib/features/bookings/data/booking_repository.dart` (concreta) |
| ⚠️ Tocca solo i propri GoRoute | `lib/core/routing/app_router.dart` |
| 🔒 Read-only | `lib/core/routing/app_routes.dart` |
| 🔒 Read-only | `lib/core/theme/**` |
| 🔒 Read-only | `lib/shared/widgets/**` |
| 🔒 NO TOUCH | `lib/features/auth/**` |
| 🔒 NO TOUCH | `lib/features/admin/**` |
| 🔒 NO TOUCH | `supabase/**` |

**Integration requirements Phase 2:**
- Dipende da: `AppRoutes.booking`, `AppRoutes.bookingDetail` (già definiti)
- Dipende da: `ISuiteRepository`, `IBookingRepository` (già definite)
- Dipende da: `appAuthProvider` per userId
- Dipende da: `Suite`, `Booking`, `BookingType`, `BookingStatus` models (già in `lib/shared/models/`)

### Agent 3 — Phase 3 Admin

| Permesso | Directory / File |
|---|---|
| ✅ Owns completamente | `lib/features/admin/**` |
| ⚠️ Tocca solo i propri GoRoute | `lib/core/routing/app_router.dart` |
| 🔒 Read-only | `lib/core/routing/app_routes.dart` |
| 🔒 Read-only | `lib/core/theme/**` |
| 🔒 Read-only | `lib/shared/widgets/**` |
| 🔒 Read-only | `lib/shared/repositories/i_suite_repository.dart` |
| 🔒 Read-only | `lib/features/bookings/domain/i_booking_repository.dart` |
| 🔒 NO TOUCH | `lib/features/auth/**` |
| 🔒 NO TOUCH | `lib/features/bookings/**` |
| 🔒 NO TOUCH | `lib/features/calendar/**` |
| 🔒 NO TOUCH | `supabase/**` |

**Integration requirements Phase 3:**
- Dipende da: `AppRoutes.admin`, `AppRoutes.adminBookings` (già definiti)
- Dipende da: `ISuiteRepository`, `IBookingRepository` (già definite)
- Dipende da: `appAuthProvider` per verifica `isSuperAdmin`
- Dipende da: implementazioni concrete di Phase 2 OPPURE crea proprie implementazioni admin (con service-role client se necessario per bypass RLS lato admin)

---

## 5. Integration Order

```
Phase 1.5  ──────────────────────────────────────►  (parallelo, no dipendenze su 2/3)
Phase 2    ──────────────────────────────────────►  (crea implementazioni concrete)
Phase 3    ──────────────────────────────────────►  (può dipendere da ISuiteRepository)
                                                ↓
                              Integration merge (app_router.dart conflicts resolve)
```

**Merge order suggerito** (se i branch devono essere integrati in sequenza):
1. Merge Phase 1.5 → main (solo theme/widgets, no conflict risk)
2. Merge Phase 2 → main (aggiunge booking routes + implementations)
3. Merge Phase 3 → main (aggiunge admin routes, risolve conflict in app_router.dart)

---

## 6. Shared Hotspots — Rischi di Conflitto

| File | Tipo rischio | Mitigation |
|---|---|---|
| `lib/core/routing/app_router.dart` | **Alto** — Phase 2 e Phase 3 entrambi aggiungono GoRoute | Inserire in aree separate della lista; Phase 2 dopo `/home`, Phase 3 dopo `/admin` |
| `lib/core/routing/app_routes.dart` | Basso — solo costanti | Freeze: non aggiungere costanti non previste |
| `lib/shared/widgets/**` | Basso | Phase 1.5 owns, altri solo leggono |
| `lib/core/theme/**` | Basso | Phase 1.5 owns, altri solo leggono |
| `lib/shared/models/**` | Basso | Freeze: non modificare model esistenti senza allineare tutti e 3 |
| `supabase/**` | **Critico** — schema DB condiviso | Freeze assoluto: nessun agent deve toccare le migration |

---

## 7. Shared Models — Freeze

I seguenti model sono **frozen** per la durata delle fasi parallele:

- `lib/shared/models/booking.dart`
- `lib/shared/models/booking_status.dart`
- `lib/shared/models/booking_type.dart`
- `lib/shared/models/suite.dart`
- `lib/shared/models/profile.dart`
- `lib/shared/models/user_role.dart`

Se un agent necessita di modificare un model, deve notificare gli altri agent e risolvere il conflitto prima del merge.

---

## 8. DB Schema Reference (read-only per tutti gli agent)

**Tabelle:**
- `profiles` — id, full_name, role (user/super_admin), created_at, updated_at
- `suites` — id, code, display_name, active, created_at
- `bookings` — id, user_id, suite_id, booking_date, booking_type (AFTERNOON_MORNING/MORNING_NIGHT/NIGHT), status (ACTIVE/CANCELLED), created_at, updated_at

**Anti-double-booking:** PARTIAL UNIQUE INDEX su `(suite_id, booking_date, booking_type) WHERE status='ACTIVE'`

**RLS:** tutti gli utenti autenticati vedono le prenotazioni attive (per verificare disponibilità). Solo super_admin modifica suites. Solo il proprietario cancella le proprie prenotazioni.

**Suite IDs fissi (seed):**
- Suite n.1: `00000000-0000-0000-0000-000000000001`
- Suite n.2: `00000000-0000-0000-0000-000000000002`
- Suite n.3: `00000000-0000-0000-0000-000000000003`
