import SwiftUI

struct StartView: View {
    @EnvironmentObject var measureManager: MeasureManager
    @State private var isShowingMeasureView = false
    
    var body: some View {
        NavigationView {
            VStack (spacing: 15) {
                if isShowingMeasureView {
                    NavigationLink(destination: SessionPagingView(), isActive: $isShowingMeasureView) {
                        EmptyView()
                    }
                    .frame(width: 0, height: 0)
                    .hidden()
                } else {
                    // TODO: Dibikin view tersendiri
                    VStack(spacing: 10){
                        Text("Care Guard")
                            .font(.title2)
                            .bold()
                        
                        Text("Your Lifeline Monitor")
                            .font(.system(size: 16, weight: .regular))
                            .padding(.bottom, 20)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.center)
                    }
                }
                
                Button(action: {
                    isShowingMeasureView = true
                }) {
                    Text("Start Tracking")
                        .font(.system(size: 20, weight: .regular))
                        .foregroundColor(.white)

                }
                .tint(.blue)
                .background(Color.blue)
                .cornerRadius(50)
                
            }
            .padding()
            .navigationBarBackButtonHidden(true)
        }
    }
}

struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        StartView()
            .environmentObject(MeasureManager())
    }
}
