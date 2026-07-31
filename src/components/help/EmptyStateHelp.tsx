import * as React from "react";
import { cn } from "@/lib/utils";
import { PackageOpen } from "lucide-react";
import { motion } from "framer-motion";

interface EmptyStateHelpProps {
  /** Main message, e.g. "You haven't added any batches yet." */
  message: string;
  /** Supplemental guidance text */
  description?: string;
  /** Label for the action CTA */
  actionLabel?: string;
  /** Callback when CTA is clicked */
  onAction?: () => void;
  /** Optional help link label */
  helpLabel?: string;
  /** Optional href for the help link */
  helpHref?: string;
  /** Optional custom icon */
  icon?: React.ReactNode;
  className?: string;
}

export function EmptyStateHelp({
  message,
  description,
  actionLabel,
  onAction,
  helpLabel,
  helpHref,
  icon,
  className,
}: EmptyStateHelpProps) {
  return (
    <motion.div
      initial={{ opacity: 0, y: 10 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.3, ease: "easeOut" }}
      className={cn(
        "flex flex-col items-center justify-center gap-3 py-12 px-6 text-center",
        className
      )}
      role="status"
      aria-live="polite"
    >
      {/* Icon */}
      <div className="flex items-center justify-center w-14 h-14 rounded-2xl bg-emerald-50 dark:bg-emerald-950/30 border border-emerald-100 dark:border-emerald-900 mb-1">
        {icon ?? (
          <PackageOpen className="h-7 w-7 text-emerald-500 dark:text-emerald-400" aria-hidden="true" />
        )}
      </div>

      {/* Message */}
      <p className="text-sm font-semibold text-foreground">{message}</p>

      {/* Description */}
      {description && (
        <p className="text-xs text-muted-foreground max-w-xs leading-relaxed">{description}</p>
      )}

      {/* CTA */}
      {actionLabel && onAction && (
        <button
          type="button"
          onClick={onAction}
          className="mt-1 inline-flex items-center px-4 py-2 rounded-lg text-xs font-semibold bg-emerald-600 hover:bg-emerald-700 text-white transition-colors shadow-sm focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-emerald-500 focus-visible:ring-offset-2"
        >
          {actionLabel}
        </button>
      )}

      {/* Learn more link */}
      {helpLabel && helpHref && (
        <a
          href={helpHref}
          className="text-xs text-emerald-600 dark:text-emerald-400 hover:underline font-medium"
          target="_blank"
          rel="noreferrer"
        >
          {helpLabel}
        </a>
      )}
    </motion.div>
  );
}
