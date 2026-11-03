class FieldBox {
    var field: String = ""
}

class OtherFieldBox {
    var field: String = ""
}

class InheritedFieldBox: FieldBox {}

func resolvedFields() {
    let box = FieldBox()
    box.field = source("fields.resolved")
    sink(box.field)  // $ hasValueFlow=fields.resolved
    sink((box as! OtherFieldBox).field)  // no flow
}

func inheritedFields() {
    let box = InheritedFieldBox()
    box.field = source("fields.inherited")
    sink((box as! FieldBox).field)  // $ hasValueFlow=fields.inherited
}

func unresolvedFieldRead() {
    let box = FieldBox()
    box.field = source("fields.unresolved-read")
    sink((box as! UnknownFieldBox).field)  // $ hasValueFlow=fields.unresolved-read
}

func unresolvedFieldStore() {
    let box = FieldBox()
    (box as! UnknownFieldBox).field = source("fields.unresolved-store")
    sink(box.field)  // $ hasValueFlow=fields.unresolved-store
}

func summarizedFieldRead() {
    let box = FieldBox()
    box.field = source("fields.summary")
    sink(TestType.readField(box))  // $ hasValueFlow=fields.summary
}

class BaseBox {
    var field: String = ""
}

class OverridingBox: BaseBox {
    override var field: String {
        get { super.field }
        set { super.field = newValue }
    }
}

class UnrelatedBox {
    var field: String = ""
}

func overriddenFieldRead(_ b: Bool, _ other: UnrelatedBox) {
    let base: BaseBox = OverridingBox()
    base.field = source("fields.override-read")
    let sub = base as! OverridingBox
    let q = b ? sub : other
    sink(q.field)  // $ hasValueFlow=fields.override-read
}
