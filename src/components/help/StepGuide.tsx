import * as React from "react";
import { Info } from "lucide-react";
import { cn } from "@/lib/utils";
import { motion } from "framer-motion";

interface StepGuideProps {
  /** Current step number (1-indexed) */
  currentStep: number;
  /** Total number of steps */
  totalSteps: number;
  /** Title describing what the user is doing on this step */
  stepTitle: string;
  /** Optional additional hint for the step */
  hint?: string;
  className?: string;
}

export function StepGuide({
  currentStep,
  totalSteps,
  stepTitle,
  hint,
  className,
}: StepGuideProps) {
  const progress = Math.round((currentStep / totalSteps) * 100);

  return (
    <motion.div
      initial={{ opacity: 0, y: -8 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.25, ease: "easeOut" }}
      className={cn(
        "rounded-xl border border-emerald-200 dark:border-emerald-800/60",
        "bg-emerald-50/70 dark:bg-emerald-950/20 px-4 py-3",
        "flex items-start gap-3",
        className
      )}
      role="status"
      aria-label={`Step ${currentStep} of ${totalSteps}: ${stepTitle}`}
    >
      <Info
        className="h-4 w-4 text-emerald-600 dark:text-emerald-400 shrink-0 mt-0.5"
        aria-hidden="true"
      />

      <div className="flex-1 min-w-0 space-y-2">
        <div className="flex items-center justify-between gap-2">
          <p className="text-xs font-semibold text-emerald-700 dark:text-emerald-300">
            Step {currentStep} of {totalSteps} — {stepTitle}
          </p>
          <span className="text-xs text-muted-foreground shrink-0">{progress}%</span>
        </div>

        {/* Progress bar */}
        <div
          className="h-1 w-full rounded-full bg-emerald-200 dark:bg-emerald-900 overflow-hidden"
          aria-hidden="true"
        >
          <motion.div
            className="h-full rounded-full bg-emerald-500 dark:bg-emerald-400"
            initial={{ width: 0 }}
            animate={{ width: `${progress}%` }}
            transition={{ duration: 0.4, ease: "easeOut" }}
          />
        </div>

        {hint && (
          <p className="text-xs text-muted-foreground leading-relaxed">{hint}</p>
        )}
      </div>
    </motion.div>
  );
}
