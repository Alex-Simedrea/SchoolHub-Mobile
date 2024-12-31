//
//  WebView.swift
//  SchoolHub
//
//  Created by Alexandru Simedrea on 24.12.2024.
//

import SwiftUI
import WebKit

struct WebViewBase {
    var url: URL
    
    @Binding var isLoading: Bool
    @Binding var error: Error?
    
    func makeCoordinator() -> WebViewBase.Coordinator {
        Coordinator(self)
    }
    
    func makeWebView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
        webView.load(request)
        return webView
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebViewBase
        
        init(_ uiWebView: WebViewBase) {
            self.parent = uiWebView
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.isLoading = true
        }
        
        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            // print("Called when the web view begins to show content.")
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
        }
        
        func webView(_ webView: WKWebView,
                     didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error)
        {
            parent.isLoading = false
            parent.error = error
        }
    }
}

// MARK: - extensions

#if os(macOS)
extension PlatformIndependentWebView: NSViewRepresentable {
    func makeNSView(context: Context) -> WKWebView {
        makeWebView(context: context)
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {}
}
#else
extension WebViewBase: UIViewRepresentable {
    func makeUIView(context: Context) -> WKWebView {
        makeWebView(context: context)
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
#endif

struct WebView: View {
    @State private var isLoading = true
    @State private var error: Error? = nil
    let url: URL?
    
    var body: some View {
        ZStack {
            if let error = error {
                VStack {
                    Image(systemName: "wifi.slash")
                        .font(.system(size: 50))
                        .foregroundColor(.red)
                    Text(error.localizedDescription)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                }
            } else if let url = url {
                WebViewBase(
                    url: url,
                    isLoading: $isLoading,
                    error: $error
                )
                
                if isLoading {
                    ProgressView()
                        .scaleEffect(2)
                }
            } else {
                Text("An error occured")
                    .foregroundColor(.red)
            }
        }
    }
}

#Preview {
    WebView(url: URL(string: "https://www.google.com"))
}
