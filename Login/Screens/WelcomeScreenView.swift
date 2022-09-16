//
//  WelcomeScreenView.swift
//  Login
//
//  Created by Kimberly Townsend on 9/15/22.
//

import SwiftUI

struct WelcomeScreenView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color("BgColor").edgesIgnoringSafeArea(.all)
                VStack {
                    Spacer()
                    Image("vsu")
                    Spacer()
                    PrimaryButton(title:"Get Started")
                    
                   NavigationLink(
                    destination: SignInScreenView().navigationBarHidden(true),
                    label: {
                        Text("Sign In")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(Color("PrimaryColor"))
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(50.0)
                            .shadow(color: Color.black.opacity(0.09), radius: 60, x: 0.0, y: 16)
                            .padding(.vertical)
                    })
                   .navigationBarHidden(true)
                    HStack{
                        Text("New around here?")
                        Text("Sign up")
                            .foregroundColor(Color("PrimaryColor"))
                    }
                }
                .padding()
            }
        }
    
    }
}

struct WelcomeScreenView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeScreenView()
    }
}
