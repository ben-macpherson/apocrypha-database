class Text < ApplicationRecord
  belongs_to :content
  belongs_to :transcriber, class_name: "Person", optional: true
  has_many :language_references, as: :record
  has_many :languages, through: :language_references, as: :record
  has_many :text_urls
  has_many :booklist_references
  has_many :booklists, through: :booklist_references
  has_many :sections
  has_many :modern_source_references, as: :record
  has_many :manuscripts, through: :modern_source_references
  has_many :person_references
  has_many :scribes, as: "Person", through: :person_references

  def find_manuscript
    self.content.parent.class == Manuscript ? self.content.parent : self.content.parent.manuscript
  end
end
