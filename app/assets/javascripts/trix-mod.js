Trix.config.textAttributes.sup = { tagName: "sup", inheritable: true }
Trix.config.textAttributes.sub = { tagName: "sub", inheritable: true }

addEventListener("trix-initialize", function(event) {
	var element = event.target
	console.log("intitilizing", event.target);
  var editor = element.editor
  var toolbarElement = element.toolbarElement
  var groupElement = toolbarElement.querySelector(".trix-button-group.trix-button-group--text-tools")
	
	groupElement.insertAdjacentHTML("beforeend", '<button type="button" class="trix-button" data-trix-attribute="sup"><sup>SUP</sup></button>')
  groupElement.insertAdjacentHTML("beforeend",'<button type="button" class="trix-button" data-trix-attribute="sub"><sub>SUB</sub></button>')
  
  var selectedAttributes = new Set
  function updateSelectedAttributes() {
    selectedAttributes = new Set
    
    var selectedRange = editor.getSelectedRange()
    if (selectedRange[0] === selectedRange[1]) { selectedRange[1]++ }
    
    var selectedPieces = editor.getDocument().getDocumentAtRange(selectedRange).getPieces()
    selectedPieces.forEach(function(piece) {
    	Object.keys(piece.getAttributes()).forEach(function(attribute) {
      	selectedAttributes.add(attribute)
      })
    })
  }
  
  function enforceExclusiveAttributes() {
    if (editor.attributeIsActive("sup") && selectedAttributes.has("sub")) {
    	editor.deactivateAttribute("sub")
      updateSelectedAttributes()
    } else if (editor.attributeIsActive("sub") && selectedAttributes.has("sup")) {
    	editor.deactivateAttribute("sup")
      updateSelectedAttributes()
    }
  }
  
	updateSelectedAttributes()
  element.addEventListener("trix-selection-change", updateSelectedAttributes) 
  element.addEventListener("trix-change", enforceExclusiveAttributes)
})
