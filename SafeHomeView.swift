import SwiftUI
import UniformTypeIdentifiers
import UIKit

private enum SafeTheme {
    static let background = Color(red: 0.035, green: 0.045, blue: 0.075)
    static let panel = Color(red: 0.075, green: 0.09, blue: 0.13)
    static let cyan = Color(red: 0.18, green: 0.88, blue: 1.0)
    static let violet = Color(red: 0.58, green: 0.38, blue: 1.0)
}

struct SafeHomeView: View {
    @State private var showSettings = false
    @State private var showFiles = false
    @State private var showImporter = false
    @State private var importedFiles: [URL] = []
    @State private var notice = "READY — SAFE MODE ACTIVE"
    @AppStorage("safe_haptics") private var hapticsEnabled = true
    @AppStorage("safe_animations") private var animationsEnabled = true

    var body: some View {
        ZStack {
            LinearGradient(colors: [SafeTheme.background, Color(red: 0.07, green: 0.035, blue: 0.12)], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            Circle().fill(SafeTheme.cyan.opacity(0.09)).frame(width: 250).blur(radius: 65).offset(x: 150, y: -330)
            Circle().fill(SafeTheme.violet.opacity(0.10)).frame(width: 240).blur(radius: 70).offset(x: -160, y: 280)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 17) {
                    header
                    devicePanel
                    toolsPanel
                    launchPanel
                    statusBar
                    footer
                }
                .padding(.horizontal, 18)
                .padding(.top, 18)
                .padding(.bottom, 28)
            }
        }
        .sheet(isPresented: $showSettings) { settingsSheet }
        .sheet(isPresented: $showFiles) { filesSheet }
        .fileImporter(isPresented: $showImporter, allowedContentTypes: [.item], allowsMultipleSelection: true, onCompletion: importFiles)
        .onAppear(perform: refreshFiles)
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("OGIOS")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .tracking(3)
                    .foregroundStyle(.white)
                Text("DEVICE TOOLKIT • SAFE EDITION")
                    .font(.system(size: 9, weight: .heavy, design: .rounded))
                    .tracking(1.6)
                    .foregroundStyle(SafeTheme.cyan)
            }
            Spacer()
            Button { showSettings = true } label: {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 19, weight: .bold))
                    .foregroundStyle(SafeTheme.cyan)
                    .frame(width: 48, height: 48)
                    .background(.black.opacity(0.35), in: Circle())
                    .overlay(Circle().stroke(SafeTheme.cyan.opacity(0.5), lineWidth: 1))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Settings")
        }
    }

    private var devicePanel: some View {
        VStack(alignment: .leading, spacing: 13) {
            sectionTitle("DEVICE STATUS", icon: "iphone.gen3")
            infoRow("iOS VERSION", UIDevice.current.systemVersion, icon: "apple.logo")
            infoRow("DEVICE TYPE", UIDevice.current.model, icon: "iphone")
            infoRow("APP MODE", "SAFE • NO SYSTEM ACCESS", icon: "checkmark.shield.fill", tint: .green)
        }
        .panelStyle()
    }

    private var toolsPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("LOCAL TOOLS", icon: "square.grid.2x2.fill")
            HStack(spacing: 10) {
                toolButton(title: "MY FILES", subtitle: "App documents", icon: "folder.fill", tint: SafeTheme.cyan) {
                    refreshFiles(); showFiles = true
                }
                toolButton(title: "IMPORT FILE", subtitle: "Copy into app", icon: "square.and.arrow.down.fill", tint: SafeTheme.violet) {
                    showImporter = true
                }
            }
            Text("Files are kept inside this app's private Documents folder. The app does not access other apps' data or modify game files.")
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.white.opacity(0.52))
                .fixedSize(horizontal: false, vertical: true)
        }
        .panelStyle()
    }

    private var launchPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("OFFICIAL LINKS", icon: "arrow.up.forward.app.fill")
            Button {
                if let url = URL(string: "https://ff.garena.com/") { UIApplication.shared.open(url) }
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "globe")
                        .font(.system(size: 19, weight: .bold))
                        .foregroundStyle(SafeTheme.cyan)
                    VStack(alignment: .leading, spacing: 3) {
                        Text("FREE FIRE WEBSITE").font(.system(size: 12, weight: .black, design: .rounded)).foregroundStyle(.white)
                        Text("Open the official website").font(.system(size: 10, weight: .medium)).foregroundStyle(.white.opacity(0.5))
                    }
                    Spacer()
                    Image(systemName: "arrow.up.right").foregroundStyle(SafeTheme.cyan)
                }
                .padding(14)
                .background(.black.opacity(0.28), in: RoundedRectangle(cornerRadius: 15))
                .overlay(RoundedRectangle(cornerRadius: 15).stroke(SafeTheme.cyan.opacity(0.28), lineWidth: 1))
            }
            .buttonStyle(.plain)
        }
        .panelStyle()
    }

    private var statusBar: some View {
        HStack(spacing: 9) {
            Circle().fill(.green).frame(width: 8, height: 8)
            Text(notice).font(.system(size: 9, weight: .heavy, design: .rounded)).tracking(0.8)
            Spacer()
            Text("SAFE").font(.system(size: 9, weight: .black, design: .rounded)).foregroundStyle(.green)
        }
        .foregroundStyle(.white.opacity(0.75))
        .padding(.horizontal, 14).padding(.vertical, 13)
        .background(.black.opacity(0.35), in: Capsule())
        .overlay(Capsule().stroke(.green.opacity(0.22), lineWidth: 1))
    }

    private var footer: some View {
        VStack(spacing: 5) {
            Text("OGIOS • SAFE EDITION").font(.system(size: 10, weight: .black, design: .rounded)).tracking(1.2).foregroundStyle(SafeTheme.cyan.opacity(0.85))
            Text("Standard iOS APIs only • No jailbreak or exploit components")
                .font(.system(size: 9, weight: .medium)).foregroundStyle(.white.opacity(0.4)).multilineTextAlignment(.center)
        }
        .padding(.top, 2)
    }

    private var settingsSheet: some View {
        NavigationStack {
            Form {
                Section("Appearance & feedback") {
                    Toggle("Animations preference", isOn: $animationsEnabled)
                    Toggle("Haptics preference", isOn: $hapticsEnabled)
                }
                Section("Safety") {
                    Label("No kernel exploit", systemImage: "checkmark.shield")
                    Label("No anti-detection routines", systemImage: "checkmark.shield")
                    Label("No game or system patching", systemImage: "checkmark.shield")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .navigationBarTrailing) { Button("Done") { showSettings = false } } }
        }
        .tint(SafeTheme.cyan)
    }

    private var filesSheet: some View {
        NavigationStack {
            List {
                if importedFiles.isEmpty {
                    VStack(spacing: 9) {
                        Image(systemName: "folder").font(.system(size: 30)).foregroundStyle(SafeTheme.cyan)
                        Text("No imported files").font(.headline)
                        Text("Use Import File to copy a document into this app.").font(.caption).foregroundStyle(.secondary).multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity).padding(.vertical, 34)
                } else {
                    ForEach(importedFiles, id: \.lastPathComponent) { file in
                        HStack {
                            Image(systemName: "doc.fill").foregroundStyle(SafeTheme.cyan)
                            VStack(alignment: .leading, spacing: 3) {
                                Text(file.lastPathComponent).lineLimit(1)
                                Text(fileSize(file)).font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                            ShareLink(item: file) { Image(systemName: "square.and.arrow.up") }
                        }
                        .swipeActions {
                            Button(role: .destructive) { deleteFile(file) } label: { Label("Delete", systemImage: "trash") }
                        }
                    }
                }
            }
            .navigationTitle("My Files")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { Button("Import") { showFiles = false; showImporter = true } }
                ToolbarItem(placement: .navigationBarTrailing) { Button("Done") { showFiles = false } }
            }
        }
        .tint(SafeTheme.cyan)
    }

    private func sectionTitle(_ title: String, icon: String) -> some View {
        Label(title, systemImage: icon)
            .font(.system(size: 11, weight: .black, design: .rounded))
            .tracking(1.25)
            .foregroundStyle(.white)
    }

    private func infoRow(_ title: String, _ value: String, icon: String, tint: Color = SafeTheme.cyan) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon).foregroundStyle(tint).frame(width: 20)
            Text(title).font(.system(size: 9, weight: .bold, design: .rounded)).foregroundStyle(.white.opacity(0.5))
            Spacer()
            Text(value).font(.system(size: 10, weight: .bold, design: .rounded)).foregroundStyle(.white).lineLimit(1)
        }
    }

    private func toolButton(title: String, subtitle: String, icon: String, tint: Color, action: @escaping () -> Void) -> some View {
        Button {
            if hapticsEnabled { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
            action()
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: icon).font(.system(size: 19, weight: .bold)).foregroundStyle(tint)
                Text(title).font(.system(size: 11, weight: .black, design: .rounded)).foregroundStyle(.white)
                Text(subtitle).font(.system(size: 9, weight: .medium)).foregroundStyle(.white.opacity(0.48))
            }
            .frame(maxWidth: .infinity, minHeight: 86, alignment: .leading)
            .padding(13)
            .background(.black.opacity(0.28), in: RoundedRectangle(cornerRadius: 15))
            .overlay(RoundedRectangle(cornerRadius: 15).stroke(tint.opacity(0.3), lineWidth: 1))
        }
        .buttonStyle(.plain)
        .animation(animationsEnabled ? .easeInOut(duration: 0.2) : nil, value: showFiles)
    }

    private func documentsFolder() -> URL {
        let base = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let folder = base.appendingPathComponent("Imported", isDirectory: true)
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder
    }

    private func refreshFiles() {
        let folder = documentsFolder()
        importedFiles = (try? FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: [.fileSizeKey], options: [.skipsHiddenFiles])) ?? []
        importedFiles.sort { $0.lastPathComponent.localizedCaseInsensitiveCompare($1.lastPathComponent) == .orderedAscending }
    }

    private func importFiles(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            var count = 0
            for source in urls {
                let granted = source.startAccessingSecurityScopedResource()
                defer { if granted { source.stopAccessingSecurityScopedResource() } }
                let destination = uniqueDestination(for: source.lastPathComponent)
                do { try FileManager.default.copyItem(at: source, to: destination); count += 1 }
                catch { notice = "IMPORT FAILED — CHECK FILE" }
            }
            refreshFiles()
            if count > 0 { notice = "IMPORTED \(count) FILE(S)" }
        case .failure:
            notice = "IMPORT CANCELLED OR FAILED"
        }
    }

    private func uniqueDestination(for name: String) -> URL {
        let folder = documentsFolder()
        let initial = folder.appendingPathComponent(name)
        guard FileManager.default.fileExists(atPath: initial.path) else { return initial }
        let base = initial.deletingPathExtension().lastPathComponent
        let ext = initial.pathExtension
        var index = 2
        while true {
            let candidateName = ext.isEmpty ? "\(base)-\(index)" : "\(base)-\(index).\(ext)"
            let candidate = folder.appendingPathComponent(candidateName)
            if !FileManager.default.fileExists(atPath: candidate.path) { return candidate }
            index += 1
        }
    }

    private func deleteFile(_ file: URL) {
        do { try FileManager.default.removeItem(at: file); refreshFiles(); notice = "FILE DELETED FROM APP STORAGE" }
        catch { notice = "DELETE FAILED" }
    }

    private func fileSize(_ url: URL) -> String {
        let bytes = (try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0
        return ByteCountFormatter.string(fromByteCount: Int64(bytes), countStyle: .file)
    }
}

private extension View {
    func panelStyle() -> some View {
        self.padding(15)
            .background(SafeTheme.panel.opacity(0.9), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(.white.opacity(0.08), lineWidth: 1))
    }
}
