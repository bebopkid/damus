//
//  FollowingView.swift
//  damus
//
//  Created by William Casarin on 2022-05-16.
//

import SwiftUI

struct FollowUserView: View {
    let target: FollowTarget
    let damus_state: DamusState
    
    var body: some View {
        HStack(alignment: .top) {
            let pmodel = ProfileModel(pubkey: target.pubkey, damus: damus_state)
            let followers = FollowersModel(damus_state: damus_state, target: target.pubkey)
            let pv = ProfileView(damus_state: damus_state, profile: pmodel, followers: followers)
            
            NavigationLink(destination: pv) {
                ProfilePicView(pubkey: target.pubkey, size: PFP_SIZE, highlight: .none, profiles: damus_state.profiles)
            
                VStack(alignment: .leading) {
                    let profile = damus_state.profiles.lookup(id: target.pubkey)
                    ProfileName(pubkey: target.pubkey, profile: profile, contacts: damus_state.contacts, show_friend_confirmed: false)
                    if let about = profile.flatMap { $0.about } {
                        Text(about)
                    }
                }
                
                Spacer()
            }
            .buttonStyle(PlainButtonStyle())
            
            FollowButtonView(target: target, follow_state: damus_state.contacts.follow_state(target.pubkey))
        }
    }
}

struct FollowersView: View {
    let damus_state: DamusState
    let whos: String
    
    @EnvironmentObject var followers: FollowersModel
    
    var body: some View {
        let profile = damus_state.profiles.lookup(id: whos)
        ScrollView {
            LazyVStack(alignment: .leading) {
                ForEach(followers.contacts, id: \.self) { pk in
                    FollowUserView(target: .pubkey(pk), damus_state: damus_state)
                }
            }
        }
        .navigationBarTitle("\(Profile.displayName(profile: profile, pubkey: whos))'s Followers")
    }
    
}

struct FollowingView: View {
    let damus_state: DamusState
    
    let following: FollowingModel
    let whos: String
    
    var body: some View {
        let profile = damus_state.profiles.lookup(id: whos)
        let who = Profile.displayName(profile: profile, pubkey: whos)
        ScrollView {
            LazyVStack(alignment: .leading) {
                ForEach(following.contacts, id: \.self) { pk in
                    FollowUserView(target: .pubkey(pk), damus_state: damus_state)
                }
            }
        }
        .onAppear {
            following.subscribe()
        }
        .onDisappear {
            following.unsubscribe()
        }
        .navigationBarTitle("\(who) following")
    }
}

/*
struct FollowingView_Previews: PreviewProvider {
    static var previews: some View {
        FollowingView(contact: <#NostrEvent#>, damus_state: <#DamusState#>)
    }
}
 */
