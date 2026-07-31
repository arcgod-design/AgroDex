import * as React from "react";
import { AnimatePresence, motion } from "framer-motion";
import { X, ChevronRight, ChevronLeft, Sparkles } from "lucide-react";
import { cn } from "@/lib/utils";

const WALKTHROUGH_KEY = "agrodex_walkthrough_complete";

interface WalkthroughStep {
  title: string;
  description: string;
  icon: React.ReactNode;
}

const STEPS: WalkthroughStep[] = [
  {
    title: "Welcome to AgroDex 🌾",
    description:
      "AgroDex fights food fraud in Indonesia by creating a permanent, tamper-proof digital trail for every crop batch — powered by Hedera blockchain and Gemini AI.",
    icon: <Sparkles className="h-8 w-8 text-emerald-500" />,
  },
  {
    title: "Register a Batch",
    description:
      'Start by registering your first crop batch. Click "Register Batch" in the navigation. Every detail you enter is permanently anchored to the Hedera Consensus Service (HCS).',
    icon: (
      <svg viewBox="0 0 32 32" className="h-8 w-8 text-emerald-500" fill="none" stroke="currentColor" strokeWidth={1.5}>
        <rect x="6" y="4" width="20" height="24" rx="3" />
        <path d="M11 12h10M11 17h7" strokeLinecap="round" />
      </svg>
    ),
  },
  {
    title: "Tokenize as NFT",
    description:
      "After registering, tokenize your batch to mint a unique NFT certificate on Hedera Token Service (HTS). This gives buyers a verifiable, immutable proof of authenticity.",
    icon: (
      <svg viewBox="0 0 32 32" className="h-8 w-8 text-emerald-500" fill="none" stroke="currentColor" strokeWidth={1.5}>
        <circle cx="16" cy="16" r="10" />
        <path d="M16 10v6l4 2" strokeLinecap="round" />
      </svg>
    ),
  },
  {
    title: "Share QR & Verify",
    description:
      "Each batch gets a unique QR code. Buyers can scan it to view the complete HCS audit trail, AI trust score, and NFT certificate — all in real time.",
    icon: (
      <svg viewBox="0 0 32 32" className="h-8 w-8 text-emerald-500" fill="none" stroke="currentColor" strokeWidth={1.5}>
        <rect x="4" y="4" width="10" height="10" rx="1.5" />
        <rect x="18" y="4" width="10" height="10" rx="1.5" />
        <rect x="4" y="18" width="10" height="10" rx="1.5" />
        <path d="M18 18h4v4h-4zM22 22h4v4h-4zM18 26h4" strokeLinecap="round" />
      </svg>
    ),
  },
  {
    title: "Monitor Risk Intelligence",
    description:
      "The Risk Intelligence dashboard automatically scores all batches for fraud signals — yield anomalies, duplicate metadata, excessive frequency, and more.",
    icon: (
      <svg viewBox="0 0 32 32" className="h-8 w-8 text-emerald-500" fill="none" stroke="currentColor" strokeWidth={1.5}>
        <path d="M4 24l7-8 5 4 7-12 5 6" strokeLinecap="round" strokeLinejoin="round" />
      </svg>
    ),
  },
  {
    title: "You're all set! 🎉",
    description:
      "Click the (?) icons throughout the app for contextual help on any field. Press Ctrl+/ anytime to search all help topics globally.",
    icon: (
      <svg viewBox="0 0 32 32" className="h-8 w-8 text-emerald-500" fill="none" stroke="currentColor" strokeWidth={1.5}>
        <path d="M16 6a5 5 0 0 1 5 5c0 3-2 4-4 5v2" strokeLinecap="round" />
        <circle cx="16" cy="24" r="1" fill="currentColor" />
      </svg>
    ),
  },
];

interface InteractiveWalkthroughProps {
  /** Force show even if already completed */
  forceShow?: boolean;
}

export function InteractiveWalkthrough({ forceShow = false }: InteractiveWalkthroughProps) {
  const [currentStep, setCurrentStep] = React.useState(0);
  const [visible, setVisible] = React.useState(false);

  React.useEffect(() => {
    if (forceShow) {
      setVisible(true);
      return;
    }
    const done = localStorage.getItem(WALKTHROUGH_KEY);
    if (!done) {
      // Small delay so page renders first
      const timer = setTimeout(() => setVisible(true), 800);
      return () => clearTimeout(timer);
    }
  }, [forceShow]);

  const dismiss = React.useCallback(() => {
    setVisible(false);
    localStorage.setItem(WALKTHROUGH_KEY, "true");
  }, []);

  const next = () => {
    if (currentStep < STEPS.length - 1) {
      setCurrentStep((s) => s + 1);
    } else {
      dismiss();
    }
  };

  const prev = () => setCurrentStep((s) => Math.max(0, s - 1));

  const step = STEPS[currentStep];

  return (
    <AnimatePresence>
      {visible && (
        <>
          {/* Backdrop */}
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            transition={{ duration: 0.2 }}
            className="fixed inset-0 bg-black/40 backdrop-blur-sm z-[200]"
            onClick={dismiss}
            aria-hidden="true"
          />

          {/* Modal */}
          <motion.div
            role="dialog"
            aria-modal="true"
            aria-label={`Onboarding step ${currentStep + 1} of ${STEPS.length}`}
            initial={{ opacity: 0, scale: 0.92, y: 20 }}
            animate={{ opacity: 1, scale: 1, y: 0 }}
            exit={{ opacity: 0, scale: 0.92, y: 20 }}
            transition={{ duration: 0.25, ease: "easeOut" }}
            className={cn(
              "fixed z-[201] inset-0 m-auto w-full max-w-md h-fit",
              "bg-card border border-border rounded-2xl shadow-2xl",
              "p-6 flex flex-col gap-5"
            )}
          >
            {/* Close */}
            <button
              type="button"
              onClick={dismiss}
              aria-label="Skip walkthrough"
              className="absolute top-4 right-4 text-muted-foreground hover:text-foreground transition-colors"
            >
              <X className="h-4 w-4" />
            </button>

            {/* Step indicator dots */}
            <div className="flex items-center gap-1.5" aria-hidden="true">
              {STEPS.map((_, i) => (
                <div
                  key={i}
                  className={cn(
                    "h-1.5 rounded-full transition-all duration-300",
                    i === currentStep
                      ? "w-6 bg-emerald-500"
                      : i < currentStep
                      ? "w-1.5 bg-emerald-300"
                      : "w-1.5 bg-muted"
                  )}
                />
              ))}
            </div>

            {/* Content */}
            <AnimatePresence mode="wait">
              <motion.div
                key={currentStep}
                initial={{ opacity: 0, x: 20 }}
                animate={{ opacity: 1, x: 0 }}
                exit={{ opacity: 0, x: -20 }}
                transition={{ duration: 0.2, ease: "easeOut" }}
                className="flex flex-col items-center gap-4 text-center"
              >
                {/* Icon */}
                <div className="flex items-center justify-center w-16 h-16 rounded-2xl bg-emerald-50 dark:bg-emerald-950/30 border border-emerald-100 dark:border-emerald-900">
                  {step.icon}
                </div>

                <div className="space-y-2">
                  <h2 className="text-lg font-bold text-foreground">{step.title}</h2>
                  <p className="text-sm text-muted-foreground leading-relaxed">{step.description}</p>
                </div>
              </motion.div>
            </AnimatePresence>

            {/* Navigation */}
            <div className="flex items-center justify-between mt-2">
              <button
                type="button"
                onClick={prev}
                disabled={currentStep === 0}
                className="flex items-center gap-1 text-xs text-muted-foreground hover:text-foreground disabled:opacity-30 disabled:cursor-not-allowed transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-emerald-500 rounded"
              >
                <ChevronLeft className="h-4 w-4" />
                Back
              </button>

              <button
                type="button"
                onClick={dismiss}
                className="text-xs text-muted-foreground hover:text-foreground transition-colors underline-offset-2 hover:underline"
              >
                Skip tour
              </button>

              <button
                type="button"
                onClick={next}
                className="flex items-center gap-1 text-xs font-semibold bg-emerald-600 hover:bg-emerald-700 text-white px-4 py-2 rounded-lg transition-colors shadow-sm focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-emerald-500"
              >
                {currentStep === STEPS.length - 1 ? "Get Started" : "Next"}
                {currentStep < STEPS.length - 1 && <ChevronRight className="h-4 w-4" />}
              </button>
            </div>
          </motion.div>
        </>
      )}
    </AnimatePresence>
  );
}
