import SwiftUI

struct SliderButton: View {
    @Binding var isOn: Bool

    var body: some View {
        ZStack {
            ZStack{
                RoundedRectangle(cornerRadius: 50)
                    .fill(isOn ? Color.red : Color.accentColor.opacity(0.25))
                    .frame(height: 60)
            }

            ZStack {
                Circle()
                    .fill(Color.red)
                    .frame(width: 60, height: 60)

                Text("SOS")
                    .foregroundColor(.white)
                    .font(.system(size: 20, weight: .bold))
            }
            .offset(x: isOn ? 55 : -60)
            .gesture(DragGesture()
                .onChanged { value in
                    isOn = value.location.x > 50
                }
            )
        }
    }
}
