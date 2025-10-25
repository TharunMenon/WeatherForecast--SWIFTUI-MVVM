//
//  ContentView.swift
//  WeatherForecast
//
//  Created by Tharun Menon on 24/10/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var m_viewModel = CCForecastViewModel()

    var body: some View {
        ZStack(alignment: .top) {
            backgroundView(for: m_viewModel.m_backgroundType, isNight: m_viewModel.m_isNight)
                .ignoresSafeArea() // Full-screen gradient background ✅

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("5 Day Forecast")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.top, 48)

                    if m_viewModel.m_dailyForecasts.isEmpty {
                        VStack(alignment: .center, spacing: 8) {
                            Text("No forecast available yet")
                                .foregroundColor(.white)
                            if !m_viewModel.m_cityName.isEmpty {
                                Text("Showing for: \(m_viewModel.m_cityName)")
                                    .foregroundColor(.white.opacity(0.9))
                                    .font(.subheadline)
                            } else {
                                Text("Allow location access or try again.")
                                    .foregroundColor(.white.opacity(0.9))
                                    .font(.subheadline)
                            }

                            Button(action: { m_viewModel.requestLocation() }) {
                                Text("Retry")
                                    .foregroundColor(.blue)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 16)
                                    .background(Color.white)
                                    .cornerRadius(8)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black.opacity(0.2))
                        .cornerRadius(8)
                    }

                    ForEach(m_viewModel.m_dailyForecasts) { day in
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(day.date, format: Date.FormatStyle().weekday())
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.black)
                                Image(systemName: iconName(for: day))
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.yellow)
                            }
                            Spacer()
                            Text("\(day.temperatureC)°")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.black)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(radius: 2)
                    }

                    Spacer(minLength: 24)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 50) // 👈 gives room for home indicator
            }
            .scrollIndicators(.hidden)
            .ignoresSafeArea(edges: .bottom) // 👈 removes black bar at bottom
        }
        .ignoresSafeArea() // 👈 ensures full view extends edge to edge
        .onAppear {
            m_viewModel.requestLocation()
        }
    }

    @ViewBuilder
    private func backgroundView(for type: CCWeatherBackgroundType, isNight: Bool) -> some View {
        switch type {
        case .sunny:
            ZStack {
                if isNight {
                    LinearGradient(colors: [Color.black.opacity(0.9), Color.blue.opacity(0.2)], startPoint: .top, endPoint: .bottom)
                } else {
                    LinearGradient(colors: [Color.blue.opacity(0.85), Color.yellow.opacity(0.28)], startPoint: .top, endPoint: .bottom)
                }

                // parallax sun / stars
                ParallaxLayer(type: .sun, isNight: isNight)
            }

        case .cloudy:
            ZStack {
                if isNight {
                    LinearGradient(colors: [Color(.systemGray6).opacity(0.18), Color(.systemGray4).opacity(0.06)], startPoint: .top, endPoint: .bottom)
                } else {
                    LinearGradient(colors: [Color(.systemGray6).opacity(0.95), Color(.systemBlue).opacity(0.12)], startPoint: .top, endPoint: .bottom)
                }

                ParallaxLayer(type: .clouds, isNight: isNight)
            }

        case .rainy:
            ZStack {
                if isNight {
                    LinearGradient(colors: [Color.black.opacity(0.9), Color.gray.opacity(0.6)], startPoint: .top, endPoint: .bottom)
                } else {
                    LinearGradient(colors: [Color.blue.opacity(0.9), Color.gray.opacity(0.65)], startPoint: .top, endPoint: .bottom)
                }

                ParallaxLayer(type: .clouds, isNight: isNight)
                RainView()
            }

        case .unknown:
            ZStack {
                LinearGradient(colors: [Color.blue.opacity(0.7), Color.green.opacity(0.15)], startPoint: .top, endPoint: .bottom)
            }
        }
    }

    // MARK: - Parallax & Rain helpers

    private enum ParallaxType {
        case sun, clouds
    }

    private struct ParallaxLayer: View {
        let type: ParallaxType
        let isNight: Bool

        @State private var phase: CGFloat = 0

        var body: some View {
            GeometryReader { geo in
                ZStack {
                    if type == .sun {
                        if isNight {
                            // faint stars
                            ForEach(0..<40, id: \.self) { i in
                                Circle()
                                    .fill(Color.white.opacity(Double.random(in: 0.02...0.12)))
                                    .frame(width: CGFloat.random(in: 1...3))
                                    .position(x: CGFloat.random(in: 0...geo.size.width), y: CGFloat.random(in: 0...geo.size.height * 0.6))
                            }
                            Image(systemName: "moon.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80)
                                .foregroundColor(Color.white.opacity(0.12))
                                .offset(x: sin(phase) * 12, y: cos(phase * 0.5) * 6)
                        } else {
                            Image(systemName: "sun.max.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: min(geo.size.width, geo.size.height) * 0.42)
                                .foregroundColor(Color.yellow.opacity(0.14))
                                .offset(x: sin(phase) * 18, y: cos(phase * 0.6) * 12)
                        }
                    } else if type == .clouds {
                        // multiple cloud layers moving at different speeds
                        ForEach(0..<3, id: \.self) { layer in
                            Image(systemName: "cloud.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 220 - CGFloat(layer * 30))
                                .foregroundColor(Color.white.opacity(0.12 + Double(layer) * 0.04))
                                .offset(x: (phase * (0.5 + CGFloat(layer) * 0.3)) - geo.size.width * 0.3, y: CGFloat(layer * -30))
                        }
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height)
                .onAppear {
                    withAnimation(.linear(duration: 18).repeatForever(autoreverses: false)) {
                        phase = .pi * 2
                    }
                }
            }
        }
    }

    private struct RainView: View {
        @State private var drops: [RainDrop] = []

        var body: some View {
            GeometryReader { geo in
                ZStack {
                    ForEach(drops) { drop in
                        Capsule()
                            .fill(Color.white.opacity(drop.opacity))
                            .frame(width: 2, height: drop.length)
                            .position(x: drop.x * geo.size.width, y: drop.y)
                            .opacity(drop.visible ? 1 : 0)
                            .onAppear {
                                withAnimation(.linear(duration: drop.duration).delay(drop.delay).repeatForever(autoreverses: false)) {
                                    if let idx = drops.firstIndex(where: { $0.id == drop.id }) {
                                        drops[idx].y = geo.size.height + 60
                                        drops[idx].visible = true
                                    }
                                }
                            }
                    }
                }
                .onAppear {
                    drops = (0..<36).map { i in
                        let x = CGFloat.random(in: 0...1)
                        let startY = CGFloat.random(in: -200...0)
                        return RainDrop(id: UUID(), x: x, y: startY, length: CGFloat.random(in: 8...18), opacity: Double.random(in: 0.06...0.18), delay: Double.random(in: 0...1.5), duration: Double.random(in: 0.9...1.6), visible: false)
                    }
                }
            }
            .allowsHitTesting(false)
        }

        private struct RainDrop: Identifiable {
            let id: UUID
            let x: CGFloat // 0..1 relative
            var y: CGFloat
            let length: CGFloat
            let opacity: Double
            let delay: Double
            let duration: Double
            var visible: Bool
        }
    }

    private func iconName(for day: CCDailyForecast) -> String {
        let lower = day.weatherMain.lowercased()
        if lower.contains("rain") { return "cloud.rain.fill" }
        if lower.contains("cloud") { return "cloud.fill" }
        return "sun.max.fill"
    }
}

#Preview {
    ContentView()
}
