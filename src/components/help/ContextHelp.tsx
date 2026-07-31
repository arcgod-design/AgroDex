import * as React from "react";
import * as PopoverPrimitive from "@radix-ui/react-popover";
import { HelpCircle, CheckCircle2, AlertTriangle, Info, X } from "lucide-react";
import { cn } from "@/lib/utils";
import { HELP } from "@/data/helpContent";
import type { HelpItem, TipType } from "@/types/help";
import { AnimatePresence, motion } from "framer-motion";
import { Badge } from "@/components/ui/badge";

// ─── Icon map for tip types ───────────────────────────────────────────────────
const TIP_ICONS: Record<TipType, React.ReactNode> = {
  tip: <CheckCircle2 className="h-3.5 w-3.5 text-emerald-500 shrink-0 mt-0.5" />,
  warning: <AlertTriangle className="h-3.5 w-3.5 text-amber-500 shrink-0 mt-0.5" />,
  info: <Info className="h-3.5 w-3.5 text-blue-500 shrink-0 mt-0.5" />,
};

const TIP_TEXT_COLORS: Record<TipType, string> = {
  tip: "text-emerald-700 dark:text-emerald-400",
  warning: "text-amber-700 dark:text-amber-400",
  info: "text-blue-700 dark:text-blue-400",
};

// ─── HelpPopoverContent ───────────────────────────────────────────────────────
function HelpPopoverContent({ item }: { item: HelpItem }) {
  const examples = Array.isArray(item.example)
    ? item.example
    : item.example
    ? [item.example]
    : [];

  return (
    <div
      // Responsive width: never exceeds 72vw on mobile, 320px on sm+
      className="w-[min(72vw,288px)] sm:w-80 space-y-3"
      role="tooltip"
      aria-label={`Help: ${item.title}`}
    >
      {/* Title — leave room for close button */}
      <div className="flex items-start gap-2 pr-5">
        <HelpCircle className="h-4 w-4 text-emerald-500 shrink-0 mt-0.5" />
        <h4 className="text-sm font-semibold text-foreground leading-tight">{item.title}</h4>
      </div>

      {/* Description */}
      <p className="text-xs text-muted-foreground leading-relaxed">{item.description}</p>

      {/* Examples */}
      {examples.length > 0 && (
        <div className="space-y-1.5">
          <p className="text-xs font-medium text-foreground">
            Example{examples.length > 1 ? "s" : ""}:
          </p>
          <div className="flex flex-wrap gap-1.5">
            {examples.map((ex) => (
              <Badge
                key={ex}
                variant="secondary"
                className="text-xs font-mono bg-emerald-50 dark:bg-emerald-950/40 text-emerald-700 dark:text-emerald-300 border border-emerald-200 dark:border-emerald-800"
              >
                {ex}
              </Badge>
            ))}
          </div>
        </div>
      )}

      {/* Tips */}
      {item.tips && item.tips.length > 0 && (
        <div className="space-y-1.5 border-t border-border pt-2">
          {item.tips.map((tip, i) => (
            <div key={i} className="flex items-start gap-1.5">
              {TIP_ICONS[tip.type]}
              <p className={cn("text-xs leading-relaxed", TIP_TEXT_COLORS[tip.type])}>
                {tip.text}
              </p>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

// ─── Main ContextHelp Component ───────────────────────────────────────────────
interface ContextHelpProps {
  /** Key from the HELP dictionary, e.g. "registration.productName" */
  helpId?: string;
  /** Alternatively pass a HelpItem object directly */
  item?: HelpItem;
  className?: string;
  /** Icon size in pixels, defaults to 14 */
  size?: number;
  /**
   * Preferred side for the popover.
   * Radix automatically flips to the opposite side when space is insufficient.
   * Defaults to "right" — safest for inline form labels.
   */
  side?: "top" | "bottom" | "left" | "right";
  /**
   * Alignment relative to the trigger.
   * Radix will shift ("partial" sticky) to stay fully in viewport.
   */
  align?: "start" | "center" | "end";
}

export function ContextHelp({
  helpId,
  item: itemProp,
  className,
  size = 14,
  side = "right",
  align = "start",
}: ContextHelpProps) {
  const item = itemProp ?? (helpId ? HELP[helpId] : null);
  const [open, setOpen] = React.useState(false);

  // Keyboard: Escape closes the popover
  React.useEffect(() => {
    if (!open) return;
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === "Escape") setOpen(false);
    };
    document.addEventListener("keydown", handleKeyDown);
    return () => document.removeEventListener("keydown", handleKeyDown);
  }, [open]);

  if (!item) return null;

  return (
    <PopoverPrimitive.Root open={open} onOpenChange={setOpen}>
      <PopoverPrimitive.Trigger asChild>
        <button
          type="button"
          aria-label={`Help: ${item.title}`}
          aria-haspopup="dialog"
          aria-expanded={open}
          className={cn(
            "inline-flex items-center justify-center rounded-full shrink-0",
            "text-muted-foreground hover:text-emerald-600 dark:hover:text-emerald-400",
            "transition-colors duration-150",
            "focus-visible:outline-none focus-visible:ring-2",
            "focus-visible:ring-emerald-500 focus-visible:ring-offset-1",
            "cursor-pointer select-none",
            className
          )}
          onClick={(e) => {
            // Prevent click bubbling into parent form/label/card
            e.stopPropagation();
            e.preventDefault();
            setOpen((prev) => !prev);
          }}
        >
          <HelpCircle
            style={{ width: size, height: size }}
            className="shrink-0"
            aria-hidden="true"
          />
        </button>
      </PopoverPrimitive.Trigger>

      {/*
        PopoverPortal renders into document.body.
        This is the key fix: the popover is NEVER clipped by any parent
        container that has overflow:hidden, overflow:clip, or a stacking
        context — including Cards, Dialogs, Drawers, Tables, Sidebars, etc.
      */}
      <PopoverPrimitive.Portal>
        <AnimatePresence>
          {open && (
            <PopoverPrimitive.Content
              asChild
              side={side}
              align={align}
              // Gap between trigger and popover edge
              sideOffset={8}
              // Fine-tune alignment so the popover doesn't sit flush with
              // the icon's edge when align="start"
              alignOffset={-4}
              // ── Radix collision detection ────────────────────────────────
              // Automatically flips to the opposite side when the preferred
              // side has insufficient viewport space.
              avoidCollisions
              // Keeps the popover at least 16px from every viewport edge.
              collisionPadding={16}
              // "partial" sticky: if the popover cannot fully fit after a
              // flip, it shifts along its axis to remain within the viewport.
              sticky="partial"
              // Prevent Radix from stealing focus (causes form re-validation)
              onOpenAutoFocus={(e) => e.preventDefault()}
              onCloseAutoFocus={(e) => e.preventDefault()}
              // z-9999 ensures visibility above: modals, dialogs, drawers,
              // sticky navbars, sidebars, and all other stacking contexts.
              style={{ zIndex: 9999 }}
            >
              <motion.div
                initial={{ opacity: 0, scale: 0.95 }}
                animate={{ opacity: 1, scale: 1 }}
                exit={{ opacity: 0, scale: 0.95 }}
                transition={{ duration: 0.15, ease: "easeOut" }}
                className={cn(
                  "relative p-4",
                  // Responsive: never wider than 72vw on mobile, 320px on sm+
                  "w-[min(72vw,288px)] sm:w-80",
                  // Constrain height for very tall content; allow scrolling
                  "max-h-[min(60vh,420px)] overflow-y-auto",
                  // Visual styling matching AgroDex design system
                  "rounded-xl shadow-xl",
                  "bg-card text-card-foreground",
                  "border border-border"
                )}
              >
                {/* Dismiss button */}
                <button
                  type="button"
                  aria-label="Close help"
                  className={cn(
                    "absolute top-2 right-2",
                    "text-muted-foreground hover:text-foreground",
                    "transition-colors",
                    "focus-visible:outline-none focus-visible:ring-1",
                    "focus-visible:ring-emerald-500 rounded"
                  )}
                  onClick={(e) => {
                    e.stopPropagation();
                    setOpen(false);
                  }}
                >
                  <X className="h-3.5 w-3.5" />
                </button>

                <HelpPopoverContent item={item} />
              </motion.div>
            </PopoverPrimitive.Content>
          )}
        </AnimatePresence>
      </PopoverPrimitive.Portal>
    </PopoverPrimitive.Root>
  );
}
