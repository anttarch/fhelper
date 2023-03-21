# TODO

## Views
- [x] Transfer View
- [x] ~~Investigate~~ Fixed overflowing in some views/pages/dialogs 

- ### Add View
    - [x] Add Isar logic for selecting cards
    - [ ] Add validation for cards limits
    - [ ] Add installments

- ### Details View
    - [x] Add Isar logic for displaying cards
    - [ ] Add installments

- ### Head View

    - #### Home Page
        - [x] Mention Transfer View
        - [x] Block transfer when isar is empty or when only one account is active
        - [ ] Add graph to today summary (optional)

    - #### Settings Page
        - [ ] Add theme settings
        - [ ] Add privacy settings
        - [ ] Add security settings
        
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
    - [ ] Add information about bills and limits

- ### Type Manager
    - [x] Refactor for single TextController use

## Isar (database)
- [ ] Add conflict verification for deletes (affects managers)
    - [x] Add confirmation for deletion
    - [ ] Handle transfers
    - [ ] Add migration for types and accounts

## Internationalization (l10n)
- [ ] Enable internationalization to default attributes

## Critical bugs
- [ ] Refactor transfer description to avoid visual bugs
        - The description is saved as ```"$originAccountName $finalAccountName"```dart to allow for convinient parsing, and the method is read with ```description.split(' ')```dart resulting in a list with 2 words, the origin and final account names.
        - Refactoring is needed to allow names with spaces (this possibly will block special characters as /.;>< ect.)


## Other
- [ ] Add default attributes
- [ ] Make textfield open datepicker, bottom sheet, etc (maybe it's possible?)
- [x] Dispose TextControllers
