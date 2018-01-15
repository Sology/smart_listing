# SmartListing

SmartListing helps creating AJAX-enabled lists of ActiveRecord collections or arrays with pagination, filtering, sorting and in-place editing.

[See it in action](http://showcase.sology.eu/smart_listing)

## Installation

Add to your Gemfile:

```ruby
gem "smart_listing"
```

Then run:

```sh
$ bundle install
```

Also, you need to add SmartListing to your asset pipeline:

```
//= require smart_listing
```

__Rails >= 5.1 users__: Rails 5.1 has dropped jQuery dependency from the default stack in favour of `rails-ujs`. SmartListing still requires jQuery so make sure that you use `jquery_ujs` from `jquery-rails` gem and have following requires in your asset pipeline before `smart_listing`:
```
//= require jquery
//= require jquery_ujs
```

### Initializer

Optionally you can also install some configuration initializer:

```sh
$ rails generate smart_listing:install
```

It will be placed in `config/initializers/smart_listing.rb` and will allow you to tweak some configuration settings like HTML classes and data attributes names.

### Custom views

SmartListing comes with some built-in views which are by default compatible with Bootstrap 3. You can easily change them after installing:

```sh
$ rails generate smart_listing:views
```

Files will be placed in `app/views/smart_listing`.

## Usage

Let's start with a controller. In order to use SmartListing, in most cases you need to include controller extensions and SmartListing helper methods:

```ruby
include SmartListing::Helper::ControllerExtensions
helper  SmartListing::Helper
```

Next, put following code in controller action you desire:

```ruby
@users = smart_listing_create(:users, User.active, partial: "users/listing")
```

This will create SmartListing named `:users` consisting of ActiveRecord scope `User.active` elements and rendered by partial `users/listing`. You can also use arrays instead of ActiveRecord collections. Just put `array: true` option just like for Kaminari.

In the main view (typically something like `index.html.erb` or `index.html.haml`), use this method to render listing:

```ruby
smart_listing_render(:users)
```

`smart_listing_render` does some magic and renders `users/listing` partial which may look like this (in HAML):

```haml
- unless smart_listing.empty?
  %table
    %thead
      %tr
        %th User name
        %th Email
    %tbody
      - smart_listing.collection.each do |user|
        %tr
          %td= user.name
          %td= user.email

  = smart_listing.paginate
- else
  %p.warning No records!
```

You can see that listing template has access to special `smart_listing` local variable which is basically an instance of `SmartListing::Helper::Builder`. It provides you with some helper methods that ease rendering of SmartListing:

* `Builder#paginate` - renders Kaminari pagination,
* `Builder#pagination_per_page_links` - display some link that allow you to customize Kaminari's `per_page`,
* `Builder#collection` - accesses underlying list of items,
* `Builder#empty?` - checks if collection is empty,
* `Builder#count` - returns collection count,
* `Builder#render` - basic template's `render` wrapper that automatically adds `smart_listing` local variable,

There are also other methods that will be described in detail below.

If you are using SmartListing with AJAX on (by default), one last thing required to make pagination (and other features) work is to create JS template for main view (typically something like `index.js.erb`):

```erb
<%= smart_listing_update(:users) %>
```

### Sorting

SmartListing supports two modes of sorting: implicit and explicit. Implicit mode is enabled by default. In this mode, you define sort columns directly in the view:

```haml
- unless smart_listing.empty?
  %table
    %thead
      %tr
        %th= smart_listing.sortable "User name", :name
        %th= smart_listing.sortable "Email", :email
    %tbody
      - smart_listing.collection.each do |user|
        %tr
          %td= user.name
          %td= user.email

  = smart_listing.paginate
- else
  %p.warning No records!
```

In this case `:name` and `:email` are sorting column names. `Builder#sortable` renders special link containing column name and sort order (either `asc`, `desc`, or empty value).

You can also specify default sort order in the controller:

```ruby
@users = smart_listing_create(:users, User.active, partial: "users/listing", default_sort: {name: "asc"})
```

Implicit mode is convenient with simple data sets. In case you want to sort by joined column names, we advise you to use explicit sorting:
```ruby
@users = smart_listing_create :users, User.active.joins(:stats), partial: "users/listing",
                              sort_attributes: [[:last_signin, "stats.last_signin_at"]],
                              default_sort: {last_signin: "desc"}
```

Note that `:sort_attributes` are array which of course means, that order of attributes matters.

There's also a possibility to specify available sort directions using `:sort_dirs` option which is by default `[nil, "asc", "desc"]`.

### List item management and in-place editing

In order to allow managing and editing list items, we need to reorganize our views a bit. Basically, each item needs to have its own partial:

```haml
- unless smart_listing.empty?
  %table
    %thead
      %tr
        %th= smart_listing.sortable "User name", "name"
        %th= smart_listing.sortable "Email", "email"
        %th
    %tbody
      - smart_listing.collection.each do |user|
        %tr.editable{data: {id: user.id}}
          = smart_listing.render partial: 'users/user', locals: {user: user}
      = smart_listing.item_new colspan: 3, link: new_user_path

  = smart_listing.paginate
- else
  %p.warning No records!
```

`<tr>` has now `editable` class and `data-id` attribute. These are essential to make it work. We've used also a new helper: `Builder#new_item`. It renders new row which is used for adding new items. `:link` needs to be valid url to new resource action which renders JS:

```ruby
<%= smart_listing_item :users, :new, @new_user, "users/form" %>
```

Note that `new` action does not need to create SmartListing (via `smart_listing_create`). It just initializes `@new_user` and renders JS view.

New partial for user (`users/user`) may look like this:
```haml
%td= user.name
%td= user.email
%td.actions= smart_listing_item_actions [{name: :show, url: user_path(user)}, {name: :edit, url: edit_user_path(user)}, {name: :destroy, url: user_path(user)}]
```

`smart_listing_item_actions` renders here links that allow to edit and destroy user item. `:show`, `:edit` and `:destroy` are built-in actions, you can also define your `:custom` actions. Again. `<td>`'s class `actions` is important.

Controller actions referenced by above urls are again plain Ruby on Rails actions that render JS like:

```erb
<%= smart_listing_item :users, :new, @user, "users/form" %>
<%= smart_listing_item :users, :edit, @user, "users/form" %>
<%= smart_listing_item :users, :destroy, @user %>
```

Partial name supplied to `smart_listing_item` (`users/form`) references `@user` as `object` and may look like this:

```haml
%td{colspan: 3}
  - if object.persisted?
    %p Edit user
  - else
    %p Add user

  = form_for object, url: object.new_record? ? users_path : user_path(object), remote: true do |f|
    %p
      Name:
      = f.text_field :name
    %p
      Email:
      = f.text_field :email
    %p= f.submit "Save"
```

And one last thing are `create` and `update` controller actions JS view:

```ruby
<%= smart_listing_item :users, :create, @user, @user.persisted? ? "users/user" : "users/form" %>
<%= smart_listing_item :users, :update, @user, @user.valid? ? "users/user" : "users/form" %>
```

### Controls (filtering)

SmartListing controls allow you to change somehow presented data. This is typically used for filtering records. Let's see how view with controls may look like:

```haml
= smart_listing_controls_for(:users) do
  .filter.input-append
    = text_field_tag :filter, '', class: "search", placeholder: "Type name here", autocomplete: "off"
    %button.btn.disabled{type: "submit"}
      %span.glyphicon.glyphicon-search
```

This gives you nice Bootstrap-enabled filter field with keychange handler. Of course you can use any other form fields in controls too.

When form field changes its value, form is submitted and request is made. This needs to be handled in controller:

```ruby
users_scope = User.active.joins(:stats)
users_scope = users_scope.like(params[:filter]) if params[:filter]
@users = smart_listing_create :users, users_scope, partial: "users/listing"
```

Then, JS view is rendered and your SmartListing updated. That's it!

### Simplified views

You don't need to create all the JS views in case you want to simply use one SmartListing per controller. Just use helper methods without their first attribute (name) ie. `smart_listing_create(User.active, partial: "users/listing")`. Then define two helper methods:

 * `smart_listing_resource` returning single object,
 * `smart_listing_collection` returning collection of objects.

SmartListing default views will user these methods to render your list properly.

### More customization

Apart from standard SmartListing initializer, you can also define custom config profiles. In order to do this, use following syntax:

```ruby
SmartListing.configure(:awesome_profile) do |config|
  # put your definitions here
end
```

In order to use this profile, create helper method named `smart_listing_config_profile` returning profile name and put into your JS `SmartListing.config.merge()` function call. `merge()` function expects parameter with config attributes hash or reads body data-attribute named `smart-listing-config`. Hash of config attributes can be obtained by using helper method `SmartListing.config(:awesome_profile).to_json`.

## Not enough?

For more information and some use cases, see the [Showcase](http://showcase.sology.eu/smart_listing)

## Credits

SmartListing uses great pagination gem Kaminari https://github.com/amatsuda/kaminari

Created by Sology http://www.sology.eu

Initial development sponsored by Smart Language Apps Limited http://smartlanguageapps.com/
