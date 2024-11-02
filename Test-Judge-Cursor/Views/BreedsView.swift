import SwiftUI

struct BreedsView: View {
    @State private var searchText = ""
    private let breedService = BreedService.shared
    
    var filteredGroups: [BreedGroup] {
        let groups = breedService.getBreedGroups()
        if searchText.isEmpty {
            return groups
        }
        return groups.map { group in
            BreedGroup(
                name: group.name,
                description: group.description,
                breeds: group.breeds.filter { $0.name.localizedCaseInsensitiveContains(searchText) },
                judgingEmphasis: group.judgingEmphasis
            )
        }.filter { !$0.breeds.isEmpty }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(filteredGroups) { group in
                    Section(header: GroupHeaderView(group: group)) {
                        ForEach(group.breeds) { breed in
                            NavigationLink(destination: BreedDetailView(breed: breed)) {
                                Text(breed.name)
                            }
                        }
                    }
                }
            }
            .navigationTitle("AKC Breeds")
            .searchable(text: $searchText, prompt: "Search breeds")
        }
    }
}

struct GroupHeaderView: View {
    let group: BreedGroup
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(group.name)
                .font(.headline)
            Text(group.description)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}

struct BreedDetailView: View {
    let breed: AKCBreed
    
    var body: some View {
        Form {
            Section("Breed Information") {
                LabeledContent("Name", value: breed.name)
                LabeledContent("Group", value: breed.group)
            }
            
            if let appearance = breed.generalAppearance {
                Section("General Appearance") {
                    Text(appearance)
                }
            }
            
            if let size = breed.size {
                Section("Size") {
                    Text(size)
                }
            }
            
            if let proportion = breed.proportion {
                Section("Proportion") {
                    Text(proportion)
                }
            }
            
            if let gait = breed.gait {
                Section("Gait") {
                    Text(gait)
                }
            }
            
            if let temperament = breed.temperament {
                Section("Temperament") {
                    Text(temperament)
                }
            }
            
            if let tips = breed.judgingTips {
                Section("Judging Tips") {
                    Text(tips)
                }
            }
            
            if let issues = breed.commonIssues {
                Section("Common Issues") {
                    Text(issues)
                }
            }
        }
        .navigationTitle(breed.name)
    }
}

#Preview {
    BreedsView()
} 