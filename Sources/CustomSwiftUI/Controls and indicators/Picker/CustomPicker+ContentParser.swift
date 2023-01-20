import SwiftUI

extension CustomPicker {
    
    @propertyWrapper struct ContentParser: CustomViewParser {
        
        @State private var optionTagValues: [CustomPickerOption.ID: SelectionValue] = [:]
        
        @State private var namespaceGenerator = CustomNamespaceGenerator()
        
        var wrappedValue: Action {
            action
        }
        
        func parse(dynamicViewOutputs: [DynamicViewOutput]) -> [CustomPickerOption] {
            let options = dynamicViewOutputs
                .map { dynamicViewOutput in
                    let id = namespaceGenerator.generate(forPath: dynamicViewOutput.path).id
                    return CustomPickerOption(
                        id: id,
                        tagValue: optionTagValues[id],
                        defaultValue: dynamicViewOutput.defaultValue as? SelectionValue? ?? nil,
                        content: bindOptionContent(dynamicViewOutput.view, id: id)
                    )
                }
            namespaceGenerator.update()
            return options
        }
        
        private func bindOptionContent(_ view: any View, id: CustomPickerOption.ID) -> any View {
            view
                .customTrait(key: CustomTagValueKey<SelectionValue>.self, value: .untagged)
                .customOnTraitChange(CustomTagValueKey<SelectionValue>.self) { tagValue in
                    switch tagValue {
                    case .tagged(let value):
                        optionTagValues[id] = value
                    case .untagged:
                        optionTagValues[id] = nil
                    }
                }
        }
    }
}
