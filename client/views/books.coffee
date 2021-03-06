# Paginated list of books
_.extend Template['books'],
  books: ->
    # Logger.info 'Template.books.books'
    sort = {}
    sort[Session.get 'sort-by'] = Session.get 'sort-order'
    books = Books.find {},
      sort: sort
      limit: Session.get 'books-per-page'

    book_values = (book) -> [
      book.name,
      book.author_name,
      book.author_surname,
      book.lang,
      book.genre,
      book.year || '', # if year is 0 then don't show it
      book.note
    ]

    add_css_classes = (values) ->
      _.map values, (value, index) ->
        value: value,
        class: Template['table-header'].columns()[index].class

    books.map (book) ->
      _.extend book,
        values: add_css_classes book_values book

  # True if books still loading
  loading: ->
    # Logger.info 'Handles.books is null: ', (Handles.books is null)
    not Handles.books?.ready()

  events:
    'click .remove-book-button': (evt) ->
      bootbox.confirm "Remove book \"#{@name}\"?", (positive_answer) =>
        Meteor.call 'remove-book', @_id if positive_answer
      evt.preventDefault()
    'click .edit-book-button': (evt) ->
      Session.set 'editing-book-id', @_id
      # Logger.info Session.get 'editing-book-id'
      Template['add-book-dialog'].show
        'default-name': @name
        'default-author-name': @author_name
        'default-author-surname': @author_surname
        'default-lang': @lang
        'default-genre': @genre
        'default-year': @year
        'default-note': @note
      evt.preventDefault()
