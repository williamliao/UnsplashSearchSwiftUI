//
//  ImageDetailView.swift
//  HelloSwiftUI_ListView
//
//  Created by 雲端開發部-廖彥勛 on 2019/8/29.
//  Copyright © 2019 雲端開發部-廖彥勛. All rights reserved.
//

import SwiftUI
import URLImage

struct ImageDetailView : View {

    /// post
    let post: Response

    var body: some View {
        
        VStack {
            URLImage(URL.init(string: post.urls.full)!,
            placeholder: {
                Image(systemName: "circle")
                    .resizable()
                    .frame(width: 150.0, height: 150.0)
            })
            .resizable()
            .aspectRatio(contentMode: .fit)

            .padding(.all, 0)
                
                HStack {
                           Button(action: {
                               
                           }, label: {
                               Text("Info")
                           })
                           Spacer()
                           Spacer()
                           Button(action: {
                               self.downloadImage()
                           }, label: {
                               Text("Download")
                           })
              }.padding()
            .navigationBarTitle(Text("\(post.urls.full)"), displayMode: .inline)
        }
    }
    
    func downloadImage() {
        
        do {
           let data = try Data(contentsOf: URL.init(string: post.urls.full)!)
            
            let image =  UIImage(data: data)
            guard let imageToBeSaved = image  else {
                return
            }
            
            UIImageWriteToSavedPhotosAlbum(imageToBeSaved, nil, nil, nil);
            
        } catch {
            print(error.localizedDescription)
        }
    }
}
/*
struct ImageDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ImageDetailView(post: Response)
    }
}*/
