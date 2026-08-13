// Encina OS - lector de pantalla sin ojos. OCR nativo, sin dependencias.
//
//     clang -fobjc-arc -framework Foundation -framework Vision -framework AppKit \
//           -o leer-pantalla leer-pantalla.m
//     ./leer-pantalla captura.png
//
// Por que existe: MEDICIONES.md 4.34l. Cuando dejan de poder cargarse capturas,
// esto lee la pantalla de una VM por lineas. Reconoce espanol e ingles.
//
// COMO SE USA BIEN, y no es opcional (SCRIPTS.md, «Como leer la pantalla de una
// VM cuando no puedes mirarla»): antes de creerse NADA de lo que devuelva, se
// dispara contra una captura QUE YA SE HA MIRADO CON LOS OJOS y se comprueba que
// devuelve lo que alli ponia. Sin ese par, un OCR que devuelve poco no se
// distingue de una pantalla vacia.
//
// Salida: una linea de texto reconocida por linea de stdout. Sin nada que
// reconocer, no imprime nada y sale 0 -- que es justo el modo de fallo que
// obliga al control de arriba.

#import <Foundation/Foundation.h>
#import <Vision/Vision.h>
#import <AppKit/AppKit.h>

int main(int argc, const char *argv[]) {
    @autoreleasepool {
        if (argc < 2) { fprintf(stderr, "uso: leer-pantalla <imagen.png>\n"); return 2; }
        NSURL *url = [NSURL fileURLWithPath:[NSString stringWithUTF8String:argv[1]]];
        NSImage *img = [[NSImage alloc] initWithContentsOfURL:url];
        if (!img) { fprintf(stderr, "[FALLO] no pude abrir %s\n", argv[1]); return 1; }
        CGImageRef cg = [img CGImageForProposedRect:NULL context:nil hints:nil];
        if (!cg) { fprintf(stderr, "[FALLO] no pude convertir a CGImage\n"); return 1; }

        VNRecognizeTextRequest *req = [[VNRecognizeTextRequest alloc] init];
        req.recognitionLevel = VNRequestTextRecognitionLevelAccurate;
        req.recognitionLanguages = @[@"es-ES", @"en-US"];
        req.usesLanguageCorrection = NO;

        VNImageRequestHandler *h = [[VNImageRequestHandler alloc] initWithCGImage:cg options:@{}];
        NSError *err = nil;
        if (![h performRequests:@[req] error:&err]) {
            fprintf(stderr, "[FALLO] Vision: %s\n", err.localizedDescription.UTF8String); return 1;
        }
        for (VNRecognizedTextObservation *o in req.results) {
            VNRecognizedText *t = [[o topCandidates:1] firstObject];
            if (t) printf("%s\n", t.string.UTF8String);
        }
    }
    return 0;
}
