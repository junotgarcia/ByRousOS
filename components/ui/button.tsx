import type { ButtonHTMLAttributes } from "react";

export type ButtonVariant = "primary" | "secondary" | "ghost";

const variantClasses: Record<ButtonVariant, string> = {
  primary: "border border-ink bg-ink text-paper hover:bg-ink/90 disabled:opacity-50",
  secondary:
    "border border-mist bg-transparent text-ink hover:border-ink/40 disabled:opacity-50",
  ghost:
    "border border-transparent bg-transparent text-ink hover:bg-mist/50 disabled:opacity-50",
};

export interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: ButtonVariant;
}

export function Button({
  variant = "primary",
  className = "",
  type = "button",
  ...rest
}: ButtonProps) {
  const base =
    "inline-flex h-11 shrink-0 items-center justify-center px-7 text-sm font-medium transition-[background-color,color,border-color] focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-ink/40";

  return (
    <button
      type={type}
      className={`${base} ${variantClasses[variant]} ${className}`}
      {...rest}
    />
  );
}
