//
//  AccountManager.swift
//  PracticeFirebase
//
//  Created by 本川晴彦 on 2023/05/25.
//
import FirebaseAuth
import AuthenticationServices
import CryptoKit



/// Firebaseの認証に関する処理を管理するシングルトンクラス
class AccountManager: NSObject {
    /// 他のクラスで使用できるようにstaticで定義
    static var shared = AccountManager()

    // 生成したナンスを保持し、検証に使用
    var currentNonce: String?

    private override init() {
        super.init()
    }

    /// ナンス生成関数
    /// ログイン リクエストごとにランダムな文字列「ナンス」を生成
    /// 取得した ID トークンが、当該アプリの認証リクエストへのレスポンスとして付与されたことを確認
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError(
                "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
            )
        }

        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")

        let nonce = randomBytes.map { byte in
            // Pick a random character from the set, wrapping around if needed.
            charset[Int(byte) % charset.count]
        }

        return String(nonce)
    }

    /// 文字列のSHA-256暗号化関数
    /// ナンスはSHA-256という規格で暗号化し、Appleに渡す
    /// Firebase では、元のノンスをハッシュ化し、Apple から渡された値と比較することで、レスポンスを検証
    /// String型を拡張し、文字列の暗号化関数を実装（import CryptoKit　必須）
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()

        return hashString
    }

    /// Appleサインインを行う関数
    /// リクエストには、ナンスの SHA256 ハッシュと、Apple のレスポンスを処理するデリゲート クラスを含める
    @available(iOS 13, *)
    func startSignInWithAppleFlow() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }

    private func deleteCurrentUser() {

            let nonce =  randomNonceString()
            currentNonce = nonce
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            request.nonce = sha256(nonce)

            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self
            authorizationController.performRequests()
    }

}

/// Apple認証画面を表示するwindowを指定
extension AccountManager: ASAuthorizationControllerPresentationContextProviding {
    /// ここでは最前面のwindowを返す
    /// 記事では取得方法が古い
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // 現行の方法は以下の３行
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        return window!
    }
}

/// Firebaseサインイン処理
/// Appleサインインの結果はASAuthorizationControllerDelegateを通して通知される
/// Appleサインインが正しく終了した場合、その情報を使ってFirebaseのアカウントを作成
extension AccountManager: ASAuthorizationControllerDelegate {

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            print("Appleサインイン完了")
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("有効なトークンが得られなかった為、処理を中断")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("トークンデータの文字列化に失敗: \(appleIDToken.debugDescription)")
                return
            }
            // Initialize a Firebase credential, including the user's full name.
            let credential = OAuthProvider.appleCredential(withIDToken: idTokenString,
                                                           rawNonce: nonce,
                                                           fullName: appleIDCredential.fullName)
            // Sign in with Firebase.
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if error != nil {
                    // Error. If error.code == .MissingOrInvalidNonce, make sure
                    // you're sending the SHA256-hashed nonce as a hex string with
                    // your request to Apple.
                    print("Firebaseサインインに失敗： \(error!.localizedDescription)")
                    return
                } else {
                    // User is signed in to Firebase with Apple.
                    print("Firebaseサインイン完了")
                }
            }
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        print("Appleサインイン失敗: \(error)")
    }
}
