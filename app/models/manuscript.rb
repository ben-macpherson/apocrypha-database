class Manuscript < ApplicationRecord
  belongs_to :institution, optional: true
  has_many :language_references, as: :record
  has_many :languages, through: :language_references, as: :record
  has_many :booklets
  has_many :modern_source_references, as: :record
  has_many :modern_sources, through: :modern_source_references
  has_many :person_references
  has_many :correspondents, class_name: "Person", through: :person_references
  has_many :provenances, class_name: "Ownership"
  has_many :contents

  before_destroy :destroy_children

  def display_name
    self.identifier.present? ? self.identifier : "Edit"
  end

end
