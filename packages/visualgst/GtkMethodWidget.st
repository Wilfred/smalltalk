GtkConcreteWidget subclass: GtkMethodWidget [
    | column methodTree model class category |

    GtkMethodWidget >> on: aClass withCategory: aCategory [
    ^ (self new)
        initialize;
	class: aClass withCategory: aCategory;
        yourself
    ]

    initialize [
	<category: 'initialization'>

	self mainWidget: self buildTreeView
    ]

    methodModel [
	<category: 'accessing'>

	^ GtkMethodModel
    ]

    class [
	<category: 'accessing'>
    
	^ class
    ]

    category [
	<category: 'accessing'>

	^ category
    ]

    category: aString [
	<category: 'accessing'>

	category := aString.
	self refreshModel
    ]

    class: aClass withCategory: aString [
	<category: 'accessing'>

	class := aClass.
	self category: aString
    ]

    model [
	<category: 'accessing'>

	^ (self methodModel currentOn: self class withCategory: self category)
	    model.
    ]

    emptyModel [
        <category: 'accessing'>

        methodTree setModel: (GTK.GtkListStore new: 1 varargs: {GTK.GValue gTypeString})
    ]

    refreshModel [
	<category: 'events'>

	methodTree setModel: self model.
        (self methodModel currentOn: self class withCategory: self category) isSorted
            ifFalse: [
                column signalEmitByName: 'clicked' args: {}.
                (self methodModel currentOn: self class withCategory: self category) sorted: true ].
    ]

    buildTreeView [
        <category: 'user interface'>
    
	methodTree := (GTK.GtkTreeView newWithSortedTextColumn: self model title: 'Classes')
                            connectSignal: 'button-press-event' to: self selector: #'onPress:event:' userData: nil;
                            yourself.
	column := methodTree getColumn: 0.
	methodTree getSelection setMode: GTK.Gtk gtkSelectionBrowse.
        (self methodModel currentOn: self class withCategory: self category) isSorted
            ifFalse: [
                column signalEmitByName: 'clicked' args: {}.
                (self methodModel currentOn: self class withCategory: self category) sorted: true ].
	^ GTK.GtkScrolledWindow withChild: methodTree
    ]

    onPress: aGtkWidget event: aGdkEvent [
        <category: 'button event'>

        | menu aGdkButtonEvent |
        aGdkButtonEvent := aGdkEvent castTo: GTK.GdkEventButton type.
        aGdkButtonEvent button value = 3 ifFalse: [ ^ false ].
        menu := GTK.GtkMenu new.
        menu appendMenuItems: {{'Rename a method'. self. #renameMethod}.
            {'Delete a method'. self. #deleteMethod}.
            {}.
            {'Inspect a method'. self. #inspectMethod}.
            {}.
            {'File out a method'. self. #fileoutMethod}}.
        menu attachToWidget: methodTree detacher: nil.
        menu popup: nil parentMenuItem: nil func: nil data: nil button: 3 activateTime: aGdkButtonEvent time value.
        menu showAll.
        ^ true
    ]

    whenSelectionChangedSend: aSelector to: anObject [
	<category: 'events'>

	methodTree getSelection
	    connectSignal: 'changed' to: anObject selector: aSelector userData: nil
    ]

    classOrMetaSelected [
	<category: 'accessing'>

	^ class
    ]

    selectedCategory [
	<category: 'accessing'>

	^ category = '*' 
	    ifTrue: [ nil ]
	    ifFalse: [ category ]
    ]

    hasSelectedMethod [
	<category: 'testing'>

	^ methodTree hasSelectedItem
    ]

    selectedMethodSymbol [
	<category: 'accessing'>

        | iter string |
        (iter := methodTree selectedIter) ifNil: [ self error: 'Nothing is selected' ].
        ^ (self model getOop: iter column: 0) asSymbol
    ]

    selectedMethod [
	<category: 'accessing'>

	self hasSelectedMethod ifFalse: [ self error: 'Nothing is selected' ].
	^ self class compiledMethodAt: self selectedMethodSymbol
    ]

    sourceCode [
	<category: 'accessing'>

	self hasSelectedMethod ifFalse: [ self error: 'Nothing is selected' ].
	^ (self class compiledMethodAt: self selectedMethodSymbol) methodSourceString
    ]

    deleteMethod [
        <category: 'method events'>

        DeleteMethodCommand on: self
    ]

    inspectMethod [
        <category: 'method events'>

    ]
]
