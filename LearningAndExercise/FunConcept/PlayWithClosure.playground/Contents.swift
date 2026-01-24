import UIKit

// Basic closure
let basicClosure = {
    print("This is a basic Closure")
}

basicClosure()

// Closure with parameter
let sayHello = {(name: String) in
    print("Hello \(name)")
}

sayHello("kamlesh")

// Closure with parameter and return type
let equalsTo = {(val1: Int, val2: Int) -> Int in
    return val1 + val2
}

print("The sum is \(equalsTo(2, 4))")

// Capturing Closure Values
var name = "Nilesh"
var expertise = "iOS"

let captureClosure = { [name] in
    // if you write in after the variable with square bracket, the closure will capture its value, so changing the variable will never affect the output.
    // with out output ([name]), it will reflect the change properly.
    // with out [], like { name in }, it will become a parameter.
    // you can see below that expertise will not change as we are not capturing expertise.
    print("Hii, I am \(name)")
    print("My expertise is \(expertise)")
}

name = "Harish"
expertise = "Android"
captureClosure()


// Closure is Reference type
func getOtput() -> (Int) -> (Int) {
    var input = 0
    
    return { output in
        input = input + output
        return input
    }
}


let obj = getOtput()
let a = obj(5)
let b = obj(10)
let c = obj(15)

print("Value of c: \(c)")       // output - 30

// Above obj is the object of the function which returns a closure, so obj is a closure now, returned by the function getOutput()
// so the initial value of input is 0
// first input = 5 so the value is 5 now
// second input = 10, so the value will be 15, that means input is 15 now.
// after that when we pass 15, the resutl will be 30. as a closure is reference it will keep the value alive.


// What are Non-Escaping Closure?
// A non-escaping means a closure will not live or remain in memory once the function that calls the closure finish execution. So Closure needs to be executed before its calling function finish execution. Closure is non-escaping by default in swift.

class TestClosure {
    
    func sample() {
        print("Sample")
    }
    
    func performAddition() {
        print("Step 1")
        add(3, 5) { result in
            sample()        // we can call it without self, as it is non-escaping closure and it does not need any reference
            print("Result: \(result)")
        }
        print("Final Step")
        
    }
    
    func add(_ num1: Int, _ num2: Int, completionHandler: (_ result: Int) -> Void) {
        print("Step 2")
        let sum = num1 + num2
        print("Step 3")
        completionHandler(sum)
    }
    
    func performSubtraction() {
        print("Step 1")
        sub(10, 5) {[weak self] result in
            self?.sample()       // Here if you won't use self or weak self it will throw error, because Escaping closure holds reference.
            print("Result: \(result)")
        }
        print("Final Step")
        
    }
    
    func sub(_ num1: Int, _ num2: Int, completionHandler: @escaping(_ result: Int) -> Void) {
        print("Step 2")
        let sum = num1 - num2
        DispatchQueue.main.asyncAfter(deadline: .now() + 10){
            print("Step 3")
            completionHandler(sum)
        }
    }
}

let testCl = TestClosure()
//testCl.performAddition()
// OUtput -
//Step 1
//Step 2
//Step 3
//Result: 8
//Final Step

testCl.performSubtraction()
// MARK: Output
//Step 1
//Step 2
//Final Step
//          Hold for 10 sec becasuse escaping closure is asynchornous in manner, so the next line won't wait for it to conclude.
//Step 3
//Result: 5


// What are escaping closure
// Escaping closre will remain in memory after the function from which they gets called finish execution. Generally used in API calls where code is running asynchronously and execution time is unknown.



//MARK: Defer in iOS
// Defer statement is used for executing code just
// before transforming program control outside the scope
// that the defer statement appears in.


var value = 0
@MainActor
func understandDefer() -> Int {
    defer{
        value = value + 1
    }
    return value
}


print(understandDefer)      // 0
print(value)                // 1


// On return the control exist the function scope,
// And just before that the value increases.
// That is why the function returns 0, but the value is 1.
// So defer will execute at the end of the loop.




func interViewQuestion() {
    print("Step 1")
    defer {
        print("Step 2")
    }
    print("Step 3")
}


// Output -
// Step 1
// Step 3
// Step 2


func multipleDefer() {
    print("Step 1")
    // First Defer
    defer {
        print("Step 2")
    }
    // Second defer
    defer{
        print("Step 4")
    }
    // Third defer
    defer {
        print("Step 5")
    }
    print("Step 3")
}


multipleDefer()
// Remember one thing that defer execute in the algo of
// Last In First Out, so the last one will execution First


// Output
// Step 1
// Step 3
// Step 5
// Step 4
// Step 2




// Nested Defer:
func nestedDefer() {
    print("Step 1")
    // First Defer
    defer {
        print("Step 2")
    }
    // Second defer
    defer{
        defer{
            print("Step 6")
        }
        print("Step 4")
    }
    // Third defer
    defer {
        print("Step 5")
    }
    print("Step 3")
}
print("Otput of Nested Defer")
nestedDefer()
// Output - Step 1, Step 3, Step 5, Step 4, Step 6, Step 2


//MARK: - Let Vs Var Performance , Static vs Class function:
// Let Vs Var in struct
struct AppDeveloperStruct {
    var technology: String
    let videos: Int
}


let app1 = AppDeveloperStruct(technology: "iOS", videos: 1)
// app1 is immutable and as it is an instance of value type
// the instance is also immutable so the the below two line will
// get errors even if technology is mutable. It will also get an error.
app1.technology = "Flutter"
app1.videos = 10




var app2 = AppDeveloperStruct(technology: "iOS", videos: 1)// Mutable
// the app2 is mutable as it is var but the videos is immutable so it will give error
app2.technology = "Android" // mutable
app2.videos = 5 // Immutable




// Let Vs Var in Class
class AppDeveloperClass {
    var technology: String
    let videos: Int


    init(technology: String, videos: Int) {
        self.technology = technology
        self.videos = videos
    }
}


let app1 = AppDeveloperClass(technology: "iOS", videos: 1)
// app1 is immutable,but as  AppDeveloperClass is reference type so
// technology change will not cause error.
app1.technology = "Flutter"
app1.videos = 10    // Only videos will give error as it is let(Immutable)


var app2 = AppDeveloperClass(technology: "iOS", videos: 1)// Mutable
// the app2 is mutable as it is var
app2.technology = "Android" // mutable
app2.videos = 5 // Immutable, will cause error.



// Static Vs Class
class Sample {
    func test() {


    }
    // Static dispatch
    static func test2() {


    }
    // Dynamic Dispatch
    class func test3() {


    }
}
// Static functions can not be inherited while class functions can be
class Sample2: Sample {
    override func test() {


    }
    // Class function can be overridden.
    override func test3() {


    }
}


