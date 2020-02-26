Sub Main
	'=======================================================
	'This program rotates an element first edge to an adjacent side.
	'
	'v1
	'
	'written by AMJ 2.26.2020
	'=======================================================
    Dim App as femap.model
    Set App = feFemap()

    Dim elemSet As femap.Set
    Set elemSet = App.feSet

    Dim iterElem As femap.Elem
    Set iterElem = App.feElem

    Dim rc As zReturnCode
    Dim userElemID As Long

    '=======================================================
	'Prompt user to select element
	'=======================================================
	'Get Elem
	lblGetInput:
	rc = elemSet.SelectID(FT_ELEM,"Select Planar Element to Rotate First Edge",userElemID)

	'Validate input is planar element
	iterElem.Get(userElemID)
	If iterElem.type <> FET_L_LAMINATE_PLATE _
		And iterElem.type <> FET_L_PLATE _
		And iterElem.type <> FET_P_LAMINATE_PLATE _
		And iterElem.Type <> FET_P_PLATE Then
		MsgBox("You must select a planar element",vbOkCancel,"Error")
		GoTo lblGetInput
	End If

	iterElem.Get(iserelemid)

	'=======================================================
	'Process element
	'=======================================================
    Dim iterNode As femap.Node
    Set iterNode = App.feNode

    Dim hold As Long
    Dim i As Long
    Dim lim As Long
    Dim nodes As Variant
	Dim midside As Boolean
	Dim quad As Boolean

	midside = False
	quad = True
	lim = 3	'upper array index for temp mode arrays (arrays are 0-indexed)

    rc = iterElem.GetFaceNodes(1,nodes)

    'Determine if element is a quad or tri, and whether or not midside nodes exist
	If nodes(4) <> 0 Then
		midside = True
	End If

	If midside Then
		If nodes(6) = 0 Then
			quad = False
			lim = 2
		End If
	Else
		If nodes(3) = 0 Then
			quad = False
			lim = 2
		End If
	End If

	'Put element nodes into temporary arrays
	Dim cNodes(0 To 3) As Long
	Dim mNodes(0 To 3) As Long

	For i = 0 To lim
		cNodes(i) = nodes(i)
		If midside Then	mNodes(i) = nodes(i + lim + 1)
	Next

	'Reassign node IDs to the elemen nodal array
	iterElem.Node(0) = cNodes(lim)
	If midside Then iterElem.Node(lim + 1) = mNodes(lim)
	For i = 1 To lim
		iterElem.Node(i) = cNodes(i - 1)
		If midside Then iterElem.Node(i + lim + 1) = mNodes(i - 1)
	Next

	'Store element in database and regen view
	Dim viewID As Long

	rc = iterElem.Put(0)

	rc = App.feAppGetActiveView(viewID)

	App.feViewRegenerate(viewID)


    
End Sub
