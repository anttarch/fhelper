# TODO

## Views
- [x] Transfer View
- [x] ~~Investigate~~ Fixed overflowing in some views/pages/dialogs 

- ### Add View
    - [x] Add Isar logic for selecting cards
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
    - [ ] Add validation for transfered value

## Managers

- ### Account Manager
    - [ ] Add information about values by account
    - [x] Refactor for single TextController use

- ### Card Manager
    - [x] Add editing logic and ui
    - [ ] Add information about bills and limits

- ### Type Manager
    - [x] Refactor for single TextController use

## Isar (database)
- [ ] Add conflict verification for deletes (affects managers)

## Internationalization (l10n)
- [ ] Enable internationalization to default attributes

## Other
- [ ] Add default attributes
- [ ] Make textfield open datepicker, bottom sheet, etc (maybe it's possible?)
- [ ] Dispose TextControllers
