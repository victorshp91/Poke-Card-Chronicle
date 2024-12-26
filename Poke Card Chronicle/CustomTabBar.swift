import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Tab

    @Binding var isCollapsed: Bool // Estado para manejar colapso
    
    var body: some View {
        VStack {
            HStack {
                // Botón de colapsar/expandir
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isCollapsed.toggle()
                    }
                }) {
                    if !isCollapsed {
                        
                        Image(systemName: "line.3.horizontal")
                            .font(.system(size: 20))
                            .foregroundColor(.red)
                            .padding()
                        
                    }
                    if isCollapsed {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 20))
                            .foregroundColor(.red)
                            .padding()
                    }
                }

                // Contenido de las pestañas
                if isCollapsed {
                    HStack {
                        ForEach(Tab.allCases, id: \.self) { tab in
                            Button(action: {
                                
                                    selectedTab = tab
                                
                            }) {
                                VStack(alignment: .center) {
                                    Image(systemName: tab.icon)
                                        .font(.system(size: 24))
                                        .foregroundColor(selectedTab == tab ? .red : .secondary)
                                    
                                  
                                }
                                .padding()
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .transition(.move(edge: .leading)) // Transición desde el borde izquierdo
                }
            }
            .padding(.horizontal)
            .background(.ultraThinMaterial)
            .cornerRadius(35)
            .shadow(
                color: Color.black.opacity(0.15),
                radius: 10,
                x: 0,
                y: 5
            )
            .padding(.bottom)
        }
    }
}

enum Tab: String, CaseIterable {
  //  case home
    case cards
    case allEntries
    case collection
    case about

    var title: String {
        switch self {
     //   case .home: return "Add"
        case .cards: return "Cards"
        case .allEntries: return "Diary"
        case .collection: return "Collection"
        case .about: return "Info"
        }
    }

    var icon: String {
        switch self {
     //   case .home: return "plus.circle"
        case .cards: return "greetingcard.fill"
        case .allEntries: return "book.fill"
        case .collection: return "tray.full.fill"
        case .about: return "info.circle.fill"
        }
    }
}
