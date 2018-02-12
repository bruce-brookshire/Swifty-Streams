final class Stream<T> {
    
    private var operations: [(() -> T?)]!
    private let parallel: Bool
    
    init (parallel: Bool = false) {
        operations = []
        self.parallel = parallel
    }
    
    init (array elements: [T], parallel: Bool = false) {
        operations = []
        for element in elements {
            operations.append({ return element })
        }
        self.parallel = parallel
    }
    
    private init (operations: [(() -> T?)], parallel: Bool) {
        self.operations = operations
        self.parallel = parallel
    }
    
    func forEach(_ lambda: @escaping (T) -> Void){
        for operation in operations {
            if let operation = operation() {
                lambda(operation)
            }
        }
    }
    
    func apply(_ lambda: @escaping (T) -> T) -> Stream<T> {
        for i in 0..<operations.count {
            operations[i] = addLambda(first: operations[i], second: lambda)
        }
        return self
    }
    
    func map<B>(_ lambda: @escaping (T) -> B) -> Stream<B>  {
        var newOperations: [(() -> B?)] = []
        for operation in operations {
            newOperations.append(addLambda(first: operation, second: lambda))
        }
        return Stream<B>(operations: newOperations, parallel: parallel)
    }
    
    func filter(_ lambda: @escaping (T) -> Bool) -> Stream<T> {
        for i in 0..<operations.count {
            operations[i] = {
                let element = self.operations[i]()
                if element != nil, lambda(element!) {
                    return element
                } else {
                    return nil
                }
                
            }
        }
        return self
    }
    
    private func addLambda<B>(first: @escaping () -> T?, second: @escaping (T) -> B?) -> (() -> B?) {
        return {
            if let first = first() {
                return second(first)
            } else {
                return nil
            }
        }
    }
    
    private func addLambda<T>(first: @escaping () -> T?, second: @escaping (T) -> T?) -> (() -> T?) {
        return {
            if let first = first() {
                return second(first)
            } else {
                return nil
            }
        }
    }
}
