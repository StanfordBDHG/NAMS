import SwiftUI

struct AlphabetSort2: View {
    // TODO see https://www.fivestars.blog/articles/section-title-index-swiftui/
    // => with
    let alphabet = ["A", "B", "C", "D", "M", "Z"]
    let values = ["Avalue", "Bvalue", "Cvalue", "Dvalue", "Mvalue", "Zvalue"]
    var body: some View {
        ScrollView {
            ScrollViewReader { value in
                ZStack{
                    List{
                        ForEach(alphabet, id: \.self) { letter in
                            Section(header: Text(verbatim: letter)) {
                                ForEach(values.filter { $0.hasPrefix(letter) }, id: \.self) { vals in
                                    Text(verbatim: vals).id(vals)
                                }
                            }.id(letter)
                        }
                    }
                    .listStyle(.plain)
                    HStack{
                        Spacer()
                        VStack {
                            Spacer()
                            VStack {
                                ForEach(0..<alphabet.count, id: \.self) { idx in
                                    Button(action: {
                                        withAnimation {
                                            value.scrollTo(alphabet[idx])
                                        }
                                    }, label: {
                                        Text(verbatim: idx % 2 == 0 ? alphabet[idx] : "\u{2022}")
                                    })
                                    .font(.caption)
                                }
                            }
                            .frame(maxHeight: .infinity)
                        }
                    }
                }
            }
        }
    }
}

struct AlphabetSort2_Previews: PreviewProvider {
    static var previews: some View {
        AlphabetSort2()
    }
}
