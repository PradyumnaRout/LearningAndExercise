//
//  MultiplePublishChangeInviewModel.swift
//  LearningAndExercise
//
//  Created by hb on 22/12/25.
//

import Foundation
/**
 @MainActor
 func performLogin() async {
     LoginapiLoaded = false
     do {
         try await Authenticator.shared.verifyPhoneNumber(countryCode: countryCode, phoneNumber: mobileNumber)
         LoginapiLoaded = true
         mobileNumberVerified = true
     } catch {
         LoginapiLoaded = true
         errorMessage = error.localizedDescription
         showToast = true
     }
 }


the above code is in my viewmodel, if I write mobileNumberVerified = true above the line LoginapiLoaded = true, then the onchange in my view is not working and if I write it below LoginapiLoaded = true it is working


.onChange(of: loginViewModel.mobileNumberVerified) { newValue in
         if newValue {
             router.push(AnyScreen({
                 VerifyView(verify: .login)
             }))
         }
     }


 
 This is a SwiftUI state-update ordering / batching issue, not a bug in your logic.

 What’s actually happening

 SwiftUI coalesces state updates that happen in the same run loop pass.
 When multiple @Published properties change together, SwiftUI may only re-render once, and the order you update them can determine which change SwiftUI notices for onChange.

 In your case:

 mobileNumberVerified = true
 LoginapiLoaded = true


 Both changes happen back-to-back on the same actor turn.

 If LoginapiLoaded is used somewhere in the view hierarchy (spinner, overlay, conditional view, etc.), SwiftUI’s diffing may cause the view to rebuild before the onChange subscription sees mobileNumberVerified change.

 When you reverse the order:

 LoginapiLoaded = true
 mobileNumberVerified = true


 SwiftUI already processed the loading change, so the second mutation triggers onChange reliably.

 Why onChange is sensitive to this

 onChange fires only when SwiftUI detects a value transition between renders.

 If:

 Multiple @Published properties update in the same cycle

 One causes a structural view update

 The other is evaluated as “already true” during reconciliation

 → onChange may never fire

 ✅ Correct & reliable fixes
 Option 1 (BEST): Trigger navigation from the async result, not onChange

 Navigation is a side effect, not UI state.

 @MainActor
 func performLogin() async {
     LoginapiLoaded = false
     do {
         try await Authenticator.shared.verifyPhoneNumber(
             countryCode: countryCode,
             phoneNumber: mobileNumber
         )

         LoginapiLoaded = true
         mobileNumberVerified = true

         router.push(AnyScreen {
             VerifyView(verify: .login)
         })
     } catch {
         LoginapiLoaded = true
         errorMessage = error.localizedDescription
         showToast = true
     }
 }


 ✔ No race
 ✔ No SwiftUI diffing issues
 ✔ Cleaner architecture

 Option 2: Force state changes onto separate run loops
 LoginapiLoaded = true

 await MainActor.run {
     mobileNumberVerified = true
 }


 or

 LoginapiLoaded = true

 DispatchQueue.main.async {
     self.mobileNumberVerified = true
 }


 This ensures SwiftUI sees two distinct updates.

 Option 3: Use .task(id:) instead of onChange
 .task(id: loginViewModel.mobileNumberVerified) {
     if loginViewModel.mobileNumberVerified {
         router.push(AnyScreen {
             VerifyView(verify: .login)
         })
     }
 }


 .task(id:) is more reliable than onChange for navigation triggers.

 ❌ What NOT to rely on

 Update order of @Published properties

 onChange for navigation side effects

 Assuming SwiftUI processes changes sequentially

 SwiftUI does not guarantee ordering.
 */
