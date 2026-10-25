// Controlador do ícone PJe no Dock: liga e desliga o PJe-Calc Cidadão.
// Clicar com o sistema desligado: liga (servidor + janela do navegador).
// Clicar com o sistema ligado: pergunta se deseja desligar.
import Cocoa

let PORTA: UInt16 = 9257

final class Controlador: NSObject, NSApplicationDelegate {
    let res = Bundle.main.resourcePath!
    var java: Process?
    var desligando = false

    func applicationDidFinishLaunching(_ n: Notification) {
        if portaEmUso() {
            // Já estava ligado (ex.: aberto antes); só mostra a janela.
            janela("abrir")
            return
        }
        let p = Process()
        p.executableURL = URL(fileURLWithPath: res + "/iniciar-pjecalc.sh")
        p.terminationHandler = { [weak self] _ in
            DispatchQueue.main.async { self?.javaTerminou() }
        }
        do { try p.run(); java = p } catch {
            alerta("Não foi possível iniciar o PJe-Calc Cidadão.\n\(error.localizedDescription)")
            NSApp.terminate(nil)
        }
    }

    // Clique no ícone do Dock com o sistema ligado
    func applicationShouldHandleReopen(_ s: NSApplication, hasVisibleWindows f: Bool) -> Bool {
        NSApp.activate(ignoringOtherApps: true)
        let a = NSAlert()
        a.messageText = "O PJe-Calc Cidadão está ligado."
        a.informativeText = "Deseja desligar o PJe-Calc Cidadão?"
        a.addButton(withTitle: "Desligar")
        a.addButton(withTitle: "Mostrar janela")
        a.addButton(withTitle: "Cancelar")
        if let img = NSImage(contentsOfFile: res + "/pje-dock.png") { a.icon = img }
        switch a.runModal() {
        case .alertFirstButtonReturn: NSApp.terminate(nil)
        case .alertSecondButtonReturn: janela("abrir")
        default: break
        }
        return false
    }

    func applicationDockMenu(_ s: NSApplication) -> NSMenu? {
        let m = NSMenu()
        m.addItem(withTitle: "Mostrar janela do PJe-Calc", action: #selector(mostrar), keyEquivalent: "")
        m.addItem(withTitle: "Desligar o PJe-Calc", action: #selector(desligar), keyEquivalent: "")
        return m
    }
    @objc func mostrar() { janela("abrir") }
    @objc func desligar() { NSApp.terminate(nil) }

    // Desligar: Dock > Encerrar, Cmd+Q, logout ou botão "Desligar"
    func applicationShouldTerminate(_ s: NSApplication) -> NSApplication.TerminateReply {
        let pids = pidsDoServidor()
        if pids.isEmpty { janela("fechar"); return .terminateNow }
        desligando = true
        DispatchQueue.global().async {
            self.janela("fechar")
            for pid in pids { kill(pid, SIGTERM) }          // encerra o Tomcat normalmente
            for _ in 0..<100 {                                // espera até 20 s
                if pids.allSatisfy({ kill($0, 0) != 0 }) { break }
                usleep(200_000)
            }
            for pid in pids where kill(pid, 0) == 0 { kill(pid, SIGKILL) }
            DispatchQueue.main.async { NSApp.reply(toApplicationShouldTerminate: true) }
        }
        return .terminateLater
    }

    // O próprio PJe-Calc foi encerrado (menu "Sair" na barra de menus)
    func javaTerminou() {
        java = nil
        if desligando { return }
        janela("fechar")
        NSApp.terminate(nil)
    }

    func pidsDoServidor() -> [pid_t] {
        if let p = java, p.isRunning { return [p.processIdentifier] }
        let out = executar("/usr/sbin/lsof", ["-t", "-nP", "-iTCP:\(PORTA)", "-sTCP:LISTEN", "-u", String(getuid())])
        return out.split(separator: "\n").compactMap { pid_t($0.trimmingCharacters(in: .whitespaces)) }
    }

    func portaEmUso() -> Bool {
        let fd = socket(AF_INET, SOCK_STREAM, 0); defer { close(fd) }
        var a = sockaddr_in(); a.sin_family = sa_family_t(AF_INET); a.sin_port = PORTA.bigEndian
        a.sin_addr.s_addr = inet_addr("127.0.0.1")
        return withUnsafePointer(to: &a) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { connect(fd, $0, socklen_t(MemoryLayout<sockaddr_in>.size)) == 0 }
        }
    }

    func janela(_ acao: String) {
        _ = executar(res + "/mac-bin/janela-pjecalc", [acao, "http://localhost:\(PORTA)/pjecalc"])
    }

    @discardableResult
    func executar(_ cmd: String, _ args: [String]) -> String {
        let p = Process(); p.executableURL = URL(fileURLWithPath: cmd); p.arguments = args
        let pipe = Pipe(); p.standardOutput = pipe; p.standardError = FileHandle.nullDevice
        do { try p.run() } catch { return "" }
        let d = pipe.fileHandleForReading.readDataToEndOfFile(); p.waitUntilExit()
        return String(data: d, encoding: .utf8) ?? ""
    }

    func alerta(_ t: String) { let a = NSAlert(); a.messageText = "PJe-Calc Cidadão"; a.informativeText = t; a.runModal() }
}

let app = NSApplication.shared
let ctl = Controlador()
app.delegate = ctl
app.setActivationPolicy(.regular)
app.run()
