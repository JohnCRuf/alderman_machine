% mins.sty
% Take minutes of meetings
% 2005-Sept-01 Jim Hefferon jhefferon (at) smcvt.edu
% --- Class structure: identification part
% ---
\ProvidesClass{mins}[2005/09/01 version 1.00 Minutes of meetings] 
\NeedsTeXFormat{LaTeX2e}

% --- Class structure: declaration of options part
% ---
% This class extends the article class
% Read all the documentclass options; pass them to article,
% unless the file "<currentoption>.min" exists, then it is loaded 
\DeclareOption*{\InputIfFileExists{\CurrentOption.min}{}{%
     \PassOptionsToClass{\CurrentOption}{article}}}
     
% --- Class structure: execution of options part % ---
\ProcessOptions \relax

% --- Class structure: declaration of options part % ---
\LoadClass{article}

% Page layout
\RequirePackage[left=1in,right=1in,top=1in,bottom=1in]{geometry}

\RequirePackage{fancyhdr} 
\fancypagestyle{firstpage}{%
	\fancyhf{} % clear all six fields 
	\renewcommand{\headrulewidth}{0pt} 
	\renewcommand{\footrulewidth}{0pt}
}
\fancypagestyle{followingpage}{%
	\fancyhf{} % clear all six fields 
	\fancyhead[RE,LO]{\show@shortcommittee, \show@date} 
	\fancyhead[LE,RO]{page \thepage} 
	\renewcommand{\headrulewidth}{0.7pt} 
	\renewcommand{\footrulewidth}{0pt}
}
\pagestyle{followingpage}
\AtBeginDocument{\thispagestyle{firstpage}}

% what is meeting
\def\@committee{None}
\newcommand{\setcommittee}[1]{\def\@committee{#1}}
\newcommand{\show@committee}{\@committee}

\def\@shortcommittee{None}
\newcommand{\setshortcommittee}[1]{\def\@shortcommittee{#1}}
\newcommand{\show@shortcommittee}{\@shortcommittee}

% who is meeting?
\def\@members{None}
\newcommand{\setmembers}[1]{\def\@members{#1}}
\newcommand{\show@members}{\@members}

% who is absent?
\global\let\@absent\@empty 
\newcommand{\setabsent}[1]{\def\@absent{#1}} 
\let\absent\setabsent % 
\newcommand{\show@absent}{\@absent}

% who is also present?
\global\let\@alsopresent\@empty 
\newcommand{\setalsopresent}[1]{\def\@alsopresent{#1}} 
\let\alsopresent\setalsopresent % 
\newcommand{\show@alsopresent}{\@alsopresent}

% who sent apologies
\global\let\@apologies\@empty
\newcommand{\setapologies}[1]{\def\@apologies{#1}} 
\let\apologies\setapologies % 
\newcommand{\show@apologies}{\@apologies}

% what day is it?
\def\@date{\today}
\newcommand{\setdate}[1]{\def\@date{#1}}
\newcommand{\show@date}{\@date}

% what role do they have (e.g., chair)
\newcommand{\role}[2]{#1~(#2)}
\newcommand{\chair}[1]{\role{#1}{Chair}}
\newcommand{\secretary}[1]{\role{#1}{Secretary}}

% Minutes or agenda?
\global\let\@isAgenda\@empty
\newcommand{\setisAgenda}[1]{\def\@isAgenda{#1}}

% environments inside the minutes 
\RequirePackage{enumitem}
\newenvironment{businesslist}[1]{% 
	%\renewcommand\theenumi{\alph{\enumi}} 
	\vspace{2ex}\par\noindent\textbf{#1}\par 
	\begin{enumerate}[label=\arabic*.]
		}{% 
	\end{enumerate} 
}

\newenvironment{business}{% 
	\begin{businesslist}{Business} 
		}{%
	\end{businesslist}
}

% basic definition of the minutes environ 
\newenvironment{minutes}{%
	\begin{center}
		\ifx\@isAgenda\@empty
   			{\large\textbf{\show@committee\\[1ex]Minutes}} \\[1ex]
			\show@date 
		\else
			{\large\textbf{\show@committee\\[1ex]Agenda}} \\[1ex]
			\show@date 
		\fi
	\end{center} 
	\vspace{1.5ex} 
	\opening@list 
	\vspace{1ex} 
	}{%
}

% material heading the minutes; final version
\newcommand{\opening@list}{
	\begin{description}
		\item[Meeting Attendees:] \show@members
		\ifx\@apologies\@empty
			\relax 
		\else
			\item[Apologies:] \show@apologies 
		\fi % 		
 		\ifx\@absent\@empty
			\relax 
		\else
			\item[Absent:] \show@absent 
		\fi %
  		\ifx\@alsopresent\@empty
    			\relax
  		\else
    			\item[Also present:] \show@alsopresent
		\fi % 
	\end{description} 
}

\newcommand{\nextmeeting}[1]{\textbf{Next Meeting:} #1}
