# TODO - 1.1.0 release

## Views
- [x] Transfer View
- [x] ~~Investigate~~ Fixed overflowing in some views/pages/dialogs 

- ### Add View
    - [x] Add Isar logic for selecting cards
    - [x] Add validation for cards limits
    - [x] Add installments

- ### Details View
    - [x] Add Isar logic for displaying cards
    - [x] Add installments

- ### Head View

    - #### Home Page
        - [x] Mention Transfer View
        - [x] Block transfer when isar is empty or when only one account is active
        
- ### Transfer View
    - [x] Add validation for transfered value
        - [x] Block transfers to the same account
        - [x] Block transfers greater than the funds available

## Managers

- ### Account Manager
    - [x] Add information about values by account
    - [x] Refactor for single TextController use

- ### Card Manager
    - [x] Add editing logic and ui
    - [x] Add information about bills and limits

- ### Type Manager
    - [x] Refactor for single TextController use

## Isar (database)
- [x] Add conflict verification for deletes (affects managers)
    - [x] Add confirmation for deletion

## Internationalization (l10n)
- [x] Enable internationalization to default attributes

## Critical bugs
- [x] Refactor transfer description to avoid visual bugs
        - The description is saved as ```"$originAccountName $finalAccountName"```dart to allow for convinient parsing, and the method is read with ```description.split(' ')```dart resulting in a list with 2 words, the origin and final account names.
        - Refactoring is needed to allow names with spaces (this possibly will block special characters as /.;>< ect.)


## Other
- [x] Add default attributes
- [x] Dispose TextControllers

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
