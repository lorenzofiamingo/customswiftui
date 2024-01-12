public struct CustomBuilderConditional<TrueContent, FalseContent> {
    
    enum Storage {
        
        case trueContent(TrueContent)
        
        case falseContent(FalseContent)
    }
    
    let storage: Storage
}
