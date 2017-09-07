# LZKVO
This project is based on the runtime

## Use

```objc

@import LZKVO;

```

##### Add 

```objc

self.person = [[Person alloc] init];
[self.person lz_addObserver:self.person forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:nil];

```

##### Listening

```objc

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
	// .....
}

```

##### Remove 

```objc

[self.person lz_removeObserver:self.person forKeyPath:@"name" context:nil];

```
