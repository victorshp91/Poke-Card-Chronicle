import SwiftUI
import SDWebImageSwiftUI

struct AllEntriesView: View {

    @FetchRequest(entity: DiaryEntry.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \DiaryEntry.entryDate, ascending: false)]) var allEntries: FetchedResults<DiaryEntry>
    @StateObject var viewModel: CardViewModel
    @StateObject var subscriptionViewModel: SubscriptionViewModel
    @State private var isTopBarpresented: Bool = true
    @State private var searchText: String = ""
    @State private var isSearchBarPresented: Bool = false
    @State private var showTodayEntriesOnly: Bool = true
    @State var showPayWall: Bool = false
    @State private var selectedDate: Date? = nil
    @State private var isDatePickerPresented = false

    var body: some View {
        ScrollView {
            
            VStack{
                if !subscriptionViewModel.hasLifetimePurchase {
                    VStack(alignment:.leading) {
                        HStack{
                            
                            VStack(alignment: .leading){
                                Text("Almost there!")
                                    .font(.headline)
                                    .foregroundColor(.red)
                                
                                Text("Only \(subscriptionViewModel.entriesLimit - allEntries.count) diary entries left in the free version.")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Image("subscription")
                                .resizable()
                                .scaledToFit()
                                .frame(width:35, height:35)
                                .foregroundColor(.yellow)
                            
                        }
                        
                        Button(action: {
                            // Acción para mostrar la pantalla de compra
                            showPayWall = true
                        }) {
                            
                                
                                Text("Unlock Unlimited Access")
                                    .font(.headline)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal)
                                    .foregroundColor(.white)
                                    .background(Color.red)
                                    .cornerRadius(8)
                            
                            
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.tertiarySystemBackground))
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 3)
                    .padding(.horizontal)
                    
                }
                if filteredEntries.isEmpty {
                    VStack {
                        Image("noData")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.gray)
                            .padding(.bottom, 10)
                        
                        Text("No entries to display")
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                } else {
                    LazyVStack(spacing: 20) {
                        ForEach(filteredEntries, id: \.id) { entry in
                            if let matchingCard = viewModel.cards.first(where: { $0.id == entry.cardId }) {
                                EntryCard(
                                    entry: entry,
                                    card: matchingCard,
                                    setName: setName(from: viewModel.sets, for: matchingCard.set_name)
                                )
                            }
                        }
                    }
                  
                    .padding(.bottom, 75)
                    .frame(maxWidth: .infinity)
                }
            }.padding(.top, 100)
                .fullScreenCover(isPresented: $showPayWall) {
                    PaywallView(subscriptionViewModel: subscriptionViewModel)
                }
            
        }.scrollDismissesKeyboard(.immediately)
            .navigationBarItems(
                leading:
                    Text("\(filteredEntries.count)")
                    .font(.headline)
                    .foregroundColor(.gray)
                
                
            )
        
            .navigationTitle("All Entries")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: HStack {
                    Button(action: { withAnimation { isSearchBarPresented = true } }) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.red)
                    }
                }
            )
            .overlay(
                SearchBarView(text: $searchText, isPresented: $isSearchBarPresented, actualSearch: Binding.constant(""), textPlaceHolder: "Search Entries Title, Text, Pokemon name...")
                    .opacity(isSearchBarPresented ? 1 : 0)
                    .transition(.slide)
                    .zIndex(isSearchBarPresented ? 1 : 0),
                alignment: .top
            )
            .overlay(
                isSearchBarPresented ? nil :
                    HStack(spacing: 10) {
                        Button(action: {
                            withAnimation {
                                isTopBarpresented.toggle()
                            }
                        }) {
                            Image(systemName: isTopBarpresented ? "chevron.right" : "chevron.left")
                                .font(.title2)
                                .foregroundColor(.red)
                        }
                        if isTopBarpresented {
                            Button("Today") {
                                selectedDate = nil
                                showTodayEntriesOnly = true
                            }
                            .padding(8)
                            .foregroundStyle(.white)
                            .background(showTodayEntriesOnly ? Color.red : Color.secondary)
                            .cornerRadius(15)
                            
                            Button("All Entries") {
                                selectedDate = nil
                                showTodayEntriesOnly = false
                            }
                            .padding(8)
                            .foregroundStyle(.white)
                            .background(!showTodayEntriesOnly && selectedDate == nil ? Color.red : Color.secondary)
                            .cornerRadius(15)
                            
                            Button("Pick Date") {
                                withAnimation {
                                    isDatePickerPresented.toggle()
                                }
                            }
                            .padding(8)
                            .foregroundStyle(.white)
                            .background(selectedDate != nil ? Color.red : Color.secondary)
                            .cornerRadius(15)
                            
                            Spacer()
                        } else {
                            Text("Filters").bold()
                                .padding(8)
                                .foregroundStyle(.white)
                                .background(.red)
                                .cornerRadius(15)
                        }
                    }
                    .padding(10)
                    .background(.ultraThinMaterial)
                    .cornerRadius(15)
                    .frame(height: 75)
                    .frame(maxWidth: isTopBarpresented ? .infinity : 220)
                    .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
                    .padding(10)
                    .animation(.easeInOut, value: isTopBarpresented),
                alignment: .top
            )
            .sheet(isPresented: $isDatePickerPresented) {
                VStack {
                    Text("Select a Date")
                        .font(.headline)
                        .padding(.bottom, 10)
                    
                    DatePicker(
                        "Pick a Date",
                        selection: Binding(
                            get: { selectedDate ?? Date() },
                            set: { newDate in
                                selectedDate = newDate
                                showTodayEntriesOnly = false
                                isDatePickerPresented = false
                            }
                        ),
                        displayedComponents: .date
                    )
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .padding()
                    
                    Spacer()
                }
                .frame(maxHeight: .infinity)
                .padding()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
    }

    private var filteredEntries: [DiaryEntry] {
        allEntries.filter { entry in
            let matchesDate: Bool
            if showTodayEntriesOnly {
                if let entryDate = entry.entryDate {
                    matchesDate = Calendar.current.isDateInToday(entryDate)
                } else {
                    matchesDate = false
                }
            } else if let selectedDate = selectedDate {
                if let entryDate = entry.entryDate {
                    matchesDate = Calendar.current.isDate(entryDate, inSameDayAs: selectedDate)
                } else {
                    matchesDate = false
                }
            } else {
                matchesDate = true
            }
            
            let matchesSearchText: Bool
            if searchText.isEmpty {
                matchesSearchText = true
            } else {
                matchesSearchText = (
                    entry.entryTitle?.localizedCaseInsensitiveContains(searchText) == true ||
                    entry.entryText?.localizedCaseInsensitiveContains(searchText) == true ||
                    entry.cardName?.localizedCaseInsensitiveContains(searchText) == true
                )
            }
            
            return matchesDate && matchesSearchText
        }
    }
}
