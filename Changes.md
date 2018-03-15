1.2.2 (March 11, 2018)
-----------

- Remove duplicated href key from config template #146 [nfilzi]
- Replace deprecated .any? with .present? #143 [AakLak]
- Development environment update #140 [mizinsky]
- Fix sanitize_params method #137 [mizinsky]
- Enable to configure global remote option and it to affects sortable helper #131 [kitabatake]
- Kaminari update [mizinsky]
- Update Readme for Rails >= 5.1 Users [mizinsky]

1.2.1 (September 28, 2017)
-----------

- Allow to render outside of controllers [bval]
- Documentation fixes [blackcofla]
- Use id.to_json so integers and uuids will both work [sevgibson]
- Fix popover in bootstrap 4 [sevgibson]
- Fix Kaminari #num_pages deprecation warning [tylerhunt]
- Add support for Turbolinks 5 [wynksaiddestroy]
- Use #empty? for AC::Params [phoffer]
- Fix indentation in some files [boy-papan]

1.2.0 (August 29, 2016)
-----------

- Rails 5 support and Kaminari update [akostadinov]
- Better handling of nested controls params
- Fix controls not fading out list. Related to #51
- Config now includes element templates
- Add ability to pass locals to list view [GeorgeDewar]

1.1.2 (April 01, 2015)
-----------

- Some bugfixing: #20, #46, #58

1.1.0 (January 26, 2015)
-----------

- Config profiles
- Remove duplicate href key [wynksaiddestroy]
- API refactoring [GCorbel]
- Feature Specs [GCorbel]
- Avoid smart listing controls double initialization [lacco]
- Turbolinks support [wynksaiddestroy]
- Better form controls handling
- Possibility to specify sort directions

1.0.0 (May 22, 2014)
-----------

- JS Events triggered on item actions
- Fix filter resetting
- Fix new item autoshow
- Possibility to pass custom title to default actions
- Confirmation tweaks
- Multiple smart listings isolation
- New sorting architecture (and implicit sorting attributes)
- Controls helper
- Slightly changed item action templates

0.9.8 (April 03, 2014)
-----------

- Custom popovers support

0.9.7 (April 01, 2014)
-----------

- Some bugfixing
- Fix listing sorting XSS bug
- Add possibility to display new item form by default
- "Save & continue" support

0.9.6 (March 28, 2014)
-----------

- Some bugfixing
- Initial setup generator

0.9.5 (March 17, 2014)
-----------

- Fix collection counting bug
- Add builtin show action
- Make CSS class and data attribute names generic and customizable (SmartListing.configure)
- Make JavaScript more customizable

0.9.4 (February 14, 2014)
-----------

- Possibility to callback action
- Changes in templates

0.9.3 (January 30, 2014)
-----------

- Possibility to specify kaminari options
- Possibility to generate views and customize them in the app
- Better custom action handling

0.9.2 (December 04, 2013)
-----------

- Add possibility to specify available page sizes in options hash

0.9.0 (November 28, 2013)
-----------

- Initial release
