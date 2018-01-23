@item_delete = lambda do |index|
  { type: 'ITEM_DELETE', index: index }
end

@item_add = lambda do |title|
  { type: 'ITEM_ADD', title: title }
end

@item_done = lambda do |index|
  { type: 'ITEM_DONE', index: index }
end
