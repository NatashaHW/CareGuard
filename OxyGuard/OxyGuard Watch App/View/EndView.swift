import SwiftUI

struct EndView: View {
    @EnvironmentObject var measureManager: MeasureManager
    @State private var navigateToStartView = false
    
    var body: some View {
        VStack {
            Button(action: {
                measureManager.stopMeasuring()
                navigateToStartView = true
            }) {
                Image(systemName: "xmark")
            }
            .tint(Color.red)
            .font(.title2)
            Text("End")
            
            NavigationLink(destination: StartView().navigationBarBackButtonHidden(true), isActive: $navigateToStartView) {
                EmptyView()
            }
            .frame(width: 0, height: 0)
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct EndView_Previews: PreviewProvider {
    static var previews: some View {
        EndView()
            .environmentObject(MeasureManager())
    }
}
