# ActivePermission

[![Gem Version](https://badge.fury.io/rb/active_permission.svg)](http://badge.fury.io/rb/active_permission)

This gem allow you load and authorize resource in Ruby on Rails inside controllers or views using rules with described permissions of user.

## Installation

Add this line to your application's Gemfile:

```
gem 'activepermission'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install activepermission

## Usage

### Define Abilities

Add a new class in `app/models/permissions.rb` with the following contents:

```
class Permissions < ActivePermission::Base
  def initialize(user = nil)
    can 'books', 'index'
    can 'books, 'show' do |catalog, book|
      catalog.published? and book.published?
    end
    can 'books, ['edit','update','destroy'] do |book|
      book.author == user
    end
  end
end
```

### Load Resource and authorization examples

```
class ApplicationController < ActionController::Base
  include ActivePermission::ControllerAdditions
private
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  def current_permissions
    @permission ||= Permission.new(current_user)
  end
end
```

```
class BooksController < ApplicationController
  resource :book, object: 'Book'
end
```

```
class BooksController < ApplicationController
  resource :book do
    Book.find(params[:id])
  end
end
```

```
class BooksController < ApplicationController
  resource :catalog, object: 'Catalog', key: :catalog_id, parent: true
  resource :book, through: :catalog, association: :books
  authorize :catalog, :book, only: :show
  authorize :book, only: [ :edit, :update, :destroy ]
end
```

```
class BooksController < ApplicationController
  resource :book, object: 'Book', only: [ :show, :destroy ]
  def show
    @book = Book.find(params[:id])
    authorize! @book
  end
  def destroy
    @book = Book.find(params[:id])
    if authorize @book, :destroy
      @book.destroy
    else
      flash[:warning] = 'Can't delete book'
    end
  end
end
```

### Check Abilities

```
<% if can? 'books', 'show', @book %>
  <%= render 'book', book: @book %>
<% end %>
```

```
<% if can? 'books', ['edit', 'update'], @book %>
  <%= render 'links', book: @book %>
<% end %>
```

### Rescue from ActivePermission::AccessDenied

```
  rescue_from ActivePermission::AccessDenied do |error|
    if @current_user
      logger.warn "#{@current_user.class}(#{@current_user.id}): #{error}"
      flash[:warning] = t('Access denied')
      redirect_to root_path
    else
      logger.warn "Anonymous: #{error}"
      flash[:warning] = t('Must be signin')
      redirect_to signin_path
    end
  end
```

```
  rescue_from ActivePermission::AccessDenied do |error|
    logger.warn "Controller: #{error.controller} Action: #{error.action} Object: #{error.object}"
    flash[:warning] = t('Access denied')
    redirect_to root_path
  end
```


## Contributing

1. Fork it ( https://github.com/[my-github-username]/activepermission/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
