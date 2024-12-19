import SwiftUI

struct cardImageShareView: View {
    let entry: DiaryEntry
    let card: Card
    let downloadedImage: Image?
    let cardLogo: Image?

    

    var body: some View {
       
            ZStack {
                // Background with downloaded image (blurred)
                if let image = downloadedImage {
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 900, height: 800)
                        .clipped()
                        .blur(radius: 20)
                        .opacity(0.7)
                }

   
                
                VStack{
                    HStack{
                        Spacer()
                        if let cardLogo = cardLogo {
                            cardLogo
                                .resizable()
                                .cornerRadius(10)
                                .scaledToFit()
                                .frame(width: 150)
                        }
                        
                    }
                    Spacer()
                }.padding()
                   
                HStack (alignment:.top){
                      
                        
                        
                        VStack(alignment: .leading, spacing: 10) {
                            
                                
                                Text("\(entry.entryTitle ?? "")")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .lineLimit(2)
                                Text("\(entry.entryDate ?? Date(), style: .date)")
                                    .font(.callout)
                                    .foregroundStyle(.secondary)
                                
                                Text("\(entry.entryText ?? "")")
                                    .font(.callout)
                            

//                            VStack(alignment: .leading, spacing: 4) {
//                                Text("Trend Price")
//                                    .font(.headline)
//                                    .foregroundColor(.gray)
//                                Text("$\(String(format: "%.2f", card.cardmarket?.prices?.trendPrice ?? 0.0))")
//                                    .font(.title2)
//                                    .fontWeight(.bold)
//                            }
//
//                            VStack(alignment: .leading, spacing: 4) {
//                                Text("Low Price")
//                                    .font(.headline)
//                                    .foregroundColor(.gray)
//                                Text("$\(String(format: "%.2f", card.cardmarket?.prices?.lowPrice ?? 0.0))")
//                                    .font(.title2)
//                                    .foregroundStyle(.red)
//                                    .fontWeight(.bold)
//                            }
//
//                            VStack(alignment: .leading, spacing: 4) {
//                                Text("Avg. Price")
//                                    .font(.headline)
//                                    .foregroundColor(.gray)
//                                Text("$\(String(format: "%.2f", card.cardmarket?.prices?.averageSellPrice ?? 0.0))")
//                                    .font(.title2)
//                                    .foregroundStyle(.green)
//                                    .fontWeight(.bold)
                            
//                            }
                            
                            
                        }                            .padding()
                            

                           
                        Spacer()
                       
                    }.padding(.leading)
                    .frame(width: 470)
                    .background(
                        Color.white.opacity(0.9)
                            .cornerRadius(15)
                            .shadow(radius: 5)
                    )
                    .offset(x: 140)
                    .rotationEffect(.degrees(-8))
                    .padding(.horizontal)
                    
                    // Display the card image (regular image)
                    HStack{
                        if let image = downloadedImage {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 450)
                                .cornerRadius(10)
                                .shadow(radius: 10)
                                .rotationEffect(.degrees(-8))
                        }
                        Spacer()
                    }.padding(.leading, 50)
                    
                VStack{
                    Spacer()
                    
                    HStack {
                        Spacer()
                        Text("POKE CARDS CHRONICLE - DIARY").bold()
                            .font(.title3)
                            .foregroundStyle(.white)
                            .shadow(radius: 5)
                        Image("logo")
                            .resizable()
                            .cornerRadius(10)
                            .scaledToFit()
                            .frame(width: 70)
                        Image("APPSTORE")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 250)
                    }
                }
                
                .padding()
            }.background(Color.black)
            .padding()
            .frame(width: 900, height: 800)
        
        
    }
}
