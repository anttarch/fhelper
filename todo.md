# TODO - 1.1.0+1 bugfix
- [ ] Fix week display
- [ ] Fix transfer's l10n strings

# TODO - 1.2.x

## General UI
- [ ] Add multi-select
    - [ ] Add bulk delete
    - Allows for selecting more than one property at a time (mr. obivious)
    - May require functions like showing information for more than one "thing"

## Security
- [ ] Add theme settings
- [ ] Add privacy settings
- [ ] Add security settings

## Cards Management
- [ ] Add minimum payment support
    - Right now (1.1.0), paying the minimum amount of a credit card bill is not supported, this feature will allow this

# TODO - undefined

## Home Page
- [ ] Add graph to today summary (optional)

## Isar (database)
- [ ] Add migration (on delete action) for types and accounts
    - [ ] Handle transfers
    - Results in migration from accounts intended for deletion, it needs to handle transfers and cards, as well as the general exchange
    - Right now (1.1.0), the default (and only) behavior is leaving this transactions on a kind of "limbo" where they have no account associated
    (this allows for recovery, once this feature is implemented)

## Cards Management
- [ ] Show next bill information on CardDetailsView (at least value)

## Other
- [ ] Make textfield open datepicker, bottom sheet, etc (maybe it's possible?)
